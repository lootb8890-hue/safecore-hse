import { Injectable, UnauthorizedException, ConflictException, NotFoundException, ForbiddenException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as argon2 from 'argon2';
import { PrismaService } from '../../common/prisma/prisma.service';

export interface RegisterUserDto {
  email: string;
  password: string;
  fullName: string;
  tenantSubdomain: string;
  role?: 'ADMIN' | 'MEMBER';
  department?: string;
  branch?: string;
}

export interface EnterpriseSetupDto {
  tenantName: string;
  subdomain: string;
  logoUrl?: string;
  primaryColor?: string;
  secondaryColor?: string;
  accentColor?: string;
  fontFamily?: string;
  isRtl?: boolean;
  adminEmail: string;
  adminPassword: string;
  adminFullName: string;
  adminDepartment?: string;
  adminBranch?: string;
}

export interface LoginDto {
  email: string;
  password: string;
  tenantSubdomain: string;
  clientDeviceId?: string;
}

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
  ) {}

  async setupEnterprise(data: EnterpriseSetupDto) {
    const subdomain = data.subdomain.toLowerCase();
    const existingTenant = await this.prisma.tenant.findUnique({
      where: { subdomain },
    });

    if (existingTenant) {
      throw new ConflictException(`Enterprise workspace subdomain [${subdomain}] is already registered.`);
    }

    const passwordHash = await argon2.hash(data.adminPassword);

    // Atomic transaction to create organization and primary admin account
    const result = await this.prisma.$transaction(async (tx) => {
      const tenant = await tx.tenant.create({
        data: {
          name: data.tenantName,
          subdomain,
          logoUrl: data.logoUrl,
          primaryColor: data.primaryColor || '#1A56DB',
          secondaryColor: data.secondaryColor || '#0E317A',
          accentColor: data.accentColor || '#F05252',
          fontFamily: data.fontFamily || 'IBM Plex Sans Arabic',
          isRtl: data.isRtl ?? true,
          branches: data.adminBranch ? [data.adminBranch] : ['Main HQ', 'Field Operational Zone'],
          departments: data.adminDepartment ? [data.adminDepartment] : ['HSE & Executive', 'Field Safety Inspection'],
        },
      });

      const adminUser = await tx.user.create({
        data: {
          tenantId: tenant.id,
          email: data.adminEmail.toLowerCase(),
          passwordHash,
          fullName: data.adminFullName,
          role: 'ADMIN', // Exclusive primary admin setup
          department: data.adminDepartment || 'Executive Command & HSE',
          branch: data.adminBranch || 'Main HQ',
        },
      });

      await tx.auditLog.create({
        data: {
          tenantId: tenant.id,
          actorId: adminUser.id,
          actionType: 'ENTERPRISE_ONBOARDED',
          targetEntity: 'TENANT',
          targetId: tenant.id,
          newValues: { name: tenant.name, admin: adminUser.email, subdomain },
        },
      });

      return { tenant, adminUser };
    });

    return this.generateTokenResponse(result.adminUser, result.tenant);
  }

  async register(data: RegisterUserDto) {
    const tenant = await this.prisma.tenant.findUnique({
      where: { subdomain: data.tenantSubdomain.toLowerCase() },
    });

    if (!tenant) {
      throw new NotFoundException(`Tenant enterprise [${data.tenantSubdomain}] not found.`);
    }

    // Prohibit self-promotion to ADMIN role through standard registration
    if (data.role === 'ADMIN') {
      throw new ForbiddenException('Admin accounts can solely be created during initial Enterprise Onboarding or via Admin User Management.');
    }

    const existingUser = await this.prisma.user.findFirst({
      where: { tenantId: tenant.id, email: data.email.toLowerCase() },
    });

    if (existingUser) {
      throw new ConflictException('A user with this email already exists within this organization.');
    }

    const passwordHash = await argon2.hash(data.password);

    const user = await this.prisma.user.create({
      data: {
        tenantId: tenant.id,
        email: data.email.toLowerCase(),
        passwordHash,
        fullName: data.fullName,
        role: 'MEMBER', // Strict enforcement of member role for regular registration
        department: data.department || 'Field Safety Division',
        branch: data.branch || 'Operational Facility',
      },
    });

    // Create immutable audit log entry
    await this.prisma.auditLog.create({
      data: {
        tenantId: tenant.id,
        actorId: user.id,
        actionType: 'USER_REGISTERED_AS_MEMBER',
        targetEntity: 'USER',
        targetId: user.id,
        newValues: { email: user.email, role: user.role, branch: user.branch },
      },
    });

    return this.generateTokenResponse(user, tenant);
  }

  async login(data: LoginDto) {
    const tenant = await this.prisma.tenant.findUnique({
      where: { subdomain: data.tenantSubdomain.toLowerCase() },
    });

    if (!tenant) {
      throw new UnauthorizedException('Invalid enterprise workspace subdomain.');
    }

    const user = await this.prisma.user.findFirst({
      where: { tenantId: tenant.id, email: data.email.toLowerCase(), isActive: true },
    });

    if (!user || !(await argon2.verify(user.passwordHash, data.password))) {
      throw new UnauthorizedException('Authentication rejected: Invalid credentials or inactive account.');
    }

    // Update last login timestamp & log audit event
    await this.prisma.user.update({
      where: { id: user.id },
      data: { lastLogin: new Date() },
    });

    await this.prisma.auditLog.create({
      data: {
        tenantId: tenant.id,
        actorId: user.id,
        actionType: 'USER_LOGGED_IN',
        targetEntity: 'USER',
        targetId: user.id,
        newValues: { device: data.clientDeviceId || 'Web/PWA/Mobile', loginAt: new Date(), role: user.role },
      },
    });

    return this.generateTokenResponse(user, tenant);
  }

  private generateTokenResponse(user: any, tenant: any) {
    const payload = {
      sub: user.id,
      email: user.email,
      role: user.role,
      tenantId: tenant.id,
    };

    return {
      accessToken: this.jwtService.sign(payload, { expiresIn: '7d' }),
      refreshToken: this.jwtService.sign(payload, { expiresIn: '30d' }),
      expiresIn: 604800,
      user: {
        id: user.id,
        email: user.email,
        fullName: user.fullName,
        role: user.role,
        department: user.department,
        branch: user.branch,
      },
      tenantBranding: {
        id: tenant.id,
        name: tenant.name,
        subdomain: tenant.subdomain,
        logoUrl: tenant.logoUrl,
        primaryColor: tenant.primaryColor,
        secondaryColor: tenant.secondaryColor,
        accentColor: tenant.accentColor,
        fontFamily: tenant.fontFamily,
        isRtl: tenant.isRtl,
      },
    };
  }
}
