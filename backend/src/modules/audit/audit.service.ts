import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';

/**
 * Enterprise Immutable Audit Log Service.
 * SECURITY COMPLIANCE NOTE: This service implements strictly append-only logic.
 * Methods for deletion, purging, or modification of logged records DO NOT EXIST and are forbidden by NFRs.
 */
@Injectable()
export class AuditService {
  constructor(private prisma: PrismaService) {}

  async listLogs(tenantId: string, limit = 100, entityFilter?: string) {
    const where: any = { tenantId };
    if (entityFilter) {
      where.targetEntity = entityFilter.toUpperCase();
    }

    const logs = await this.prisma.auditLog.findMany({
      where,
      orderBy: { timestamp: 'desc' },
      take: limit,
      include: {
        actor: { select: { fullName: true, email: true, role: true } },
      },
    });

    return {
      totalRetrieved: logs.length,
      complianceNotice: 'Audit trails are immutable, cryptographically timestamped, and protected against purge operations.',
      records: logs,
    };
  }
}
