import { Injectable, UnauthorizedException, ConflictException, NotFoundException } from '@nestjs/common';
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

  async register(data: RegisterUserDto) {
    const tenant = await this.prisma.tenant.findUnique({
      where: { subdomain: data.tenantSubdomain.toLowerCase() },
    });

    if (!tenant) {
      throw new NotFoundException(`Tenant enterprise [${data.tenantSubdomain}] not found.`);
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
        role: data.role || 'MEMBER',
        department: data.department,
        branch: data.branch,
      },
    });

    // Create immutable audit log entry
    await this.prisma.auditLog.create({
      data: {
        tenantId: tenant.id,
        actorId: user.id,
        actionType: 'USER_REGISTERED',
        targetEntity: 'USER',
        targetId: user.id,
        newValues: { email: user.email, role: user.role },
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
        newValues: { device: data.clientDeviceId || 'Web/PWA', loginAt: new Date() },
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
