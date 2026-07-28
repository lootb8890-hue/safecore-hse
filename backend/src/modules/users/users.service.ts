import { Injectable, ConflictException, NotFoundException } from '@nestjs/common';
import * as argon2 from 'argon2';
import { PrismaService } from '../../common/prisma/prisma.service';

export interface CreateMemberDto {
  email: string;
  fullName: string;
  password?: string;
  department?: string;
  branch?: string;
  role?: 'ADMIN' | 'MEMBER';
}

export interface UpdateMemberDto {
  fullName?: string;
  department?: string;
  branch?: string;
  role?: 'ADMIN' | 'MEMBER';
  isActive?: boolean;
}

@Injectable()
export class UsersService {
  constructor(private prisma: PrismaService) {}

  async createMember(tenantId: string, adminId: string, data: CreateMemberDto) {
    const email = data.email.toLowerCase();
    const existingUser = await this.prisma.user.findFirst({
      where: { tenantId, email },
    });

    if (existingUser) {
      throw new ConflictException(`Member with email [${email}] already exists in this organization.`);
    }

    const initialPassword = data.password || 'SafeCore@2026!';
    const passwordHash = await argon2.hash(initialPassword);

    const newMember = await this.prisma.user.create({
      data: {
        tenantId,
        email,
        passwordHash,
        fullName: data.fullName,
        role: data.role || 'MEMBER',
        department: data.department || 'Field Safety Division',
        branch: data.branch || 'Main Operations Facility',
        isActive: true,
      },
      select: {
        id: true,
        email: true,
        fullName: true,
        role: true,
        department: true,
        branch: true,
        isActive: true,
        createdAt: true,
      },
    });

    await this.prisma.auditLog.create({
      data: {
        tenantId,
        actorId: adminId,
        actionType: 'MEMBER_PROVISIONED_BY_ADMIN',
        targetEntity: 'USER',
        targetId: newMember.id,
        newValues: { email: newMember.email, role: newMember.role, department: newMember.department },
      },
    });

    return {
      success: true,
      message: 'Team member successfully onboarded by Admin Governance.',
      member: newMember,
      initialPasswordAssigned: data.password ? 'Custom Specified' : 'Default (SafeCore@2026!)',
    };
  }

  async getMembers(tenantId: string) {
    return this.prisma.user.findMany({
      where: { tenantId },
      select: {
        id: true,
        email: true,
        fullName: true,
        role: true,
        department: true,
        branch: true,
        isActive: true,
        lastLogin: true,
        createdAt: true,
      },
      orderBy: [{ role: 'asc' }, { createdAt: 'desc' }],
    });
  }

  async updateMember(tenantId: string, memberId: string, adminId: string, data: UpdateMemberDto) {
    const member = await this.prisma.user.findFirst({
      where: { id: memberId, tenantId },
    });

    if (!member) {
      throw new NotFoundException('Member profile not found in active tenant scope.');
    }

    const updated = await this.prisma.user.update({
      where: { id: memberId },
      data: {
        fullName: data.fullName,
        department: data.department,
        branch: data.branch,
        role: data.role,
        isActive: data.isActive,
      },
      select: {
        id: true,
        email: true,
        fullName: true,
        role: true,
        department: true,
        branch: true,
        isActive: true,
      },
    });

    await this.prisma.auditLog.create({
      data: {
        tenantId,
        actorId: adminId,
        actionType: 'MEMBER_PROFILE_UPDATED',
        targetEntity: 'USER',
        targetId: memberId,
        oldValues: { role: member.role, department: member.department, isActive: member.isActive },
        newValues: { role: updated.role, department: updated.department, isActive: updated.isActive },
      },
    });

    return updated;
  }

  async removeMember(tenantId: string, memberId: string, adminId: string) {
    const member = await this.prisma.user.findFirst({
      where: { id: memberId, tenantId },
    });

    if (!member) {
      throw new NotFoundException('Target member not found.');
    }

    // Rather than destructive physical purge (which breaks immutable safety inspection foreign keys),
    // we set isActive to false and record full audit trail.
    await this.prisma.user.update({
      where: { id: memberId },
      data: { isActive: false },
    });

    await this.prisma.auditLog.create({
      data: {
        tenantId,
        actorId: adminId,
        actionType: 'MEMBER_DEACTIVATED',
        targetEntity: 'USER',
        targetId: memberId,
        oldValues: { email: member.email, isActive: true },
        newValues: { isActive: false },
      },
    });

    return { success: true, message: 'Member account successfully revoked and decommissioned.' };
  }
}
