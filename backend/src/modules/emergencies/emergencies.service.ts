import { Injectable, NotFoundException, Logger } from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';
import { EmergenciesGateway } from './emergencies.gateway';

export interface TriggerEmergencyDto {
  emergencyType: 'FIRE' | 'INJURY' | 'GAS_LEAK' | 'ELECTRICAL_SHORT' | 'HAZMAT' | 'EVACUATION';
  locationText: string;
  layoutId?: string;
  coordX?: number;
  coordY?: number;
  mediaUrls?: string[];
  initialActions?: string;
}

export interface ResolveIncidentDto {
  correctiveActions: string;
  status: 'UNDER_INVESTIGATION' | 'RESOLVED' | 'CLOSED';
}

@Injectable()
export class EmergenciesService {
  private readonly logger = new Logger(EmergenciesService.name);

  constructor(
    private prisma: PrismaService,
    private gateway: EmergenciesGateway,
  ) {}

  async triggerEmergency(tenantId: string, reporterId: string, data: TriggerEmergencyDto) {
    const reporter = await this.prisma.user.findUnique({
      where: { id: reporterId },
      select: { fullName: true, email: true, role: true },
    });

    // Create immutable critical incident report in PostgreSQL
    const incident = await this.prisma.incident.create({
      data: {
        tenantId,
        emergencyType: data.emergencyType as any,
        reportedById: reporterId,
        locationText: data.locationText,
        layoutId: data.layoutId,
        coordX: data.coordX,
        coordY: data.coordY,
        severity: 'CRITICAL',
        status: 'ACTIVE_ALARM',
        mediaUrls: data.mediaUrls || [],
        correctiveActions: data.initialActions,
      },
    });

    // Zero-Latency Real-Time Siren Broadcast to all safety officer devices
    const broadcastPayload = {
      incidentId: incident.id,
      type: data.emergencyType,
      severity: 'CRITICAL',
      reportedByName: reporter?.fullName || 'Anonymous Safety Inspector',
      locationText: data.locationText,
      coordX: data.coordX,
      coordY: data.coordY,
      timestamp: incident.reportedAt,
      sirenAudioPattern: `ALARM_SOUND_${data.emergencyType}`,
    };

    this.gateway.broadcastEmergencySiren(tenantId, broadcastPayload);

    // Immutable Audit Log
    await this.prisma.auditLog.create({
      data: {
        tenantId,
        actorId: reporterId,
        actionType: 'EMERGENCY_SIREN_TRIGGERED',
        targetEntity: 'INCIDENT',
        targetId: incident.id,
        newValues: broadcastPayload as any,
      },
    });

    this.logger.warn(`🔥 INCIDENT FIRED IN TENANT [${tenantId}] - TYPE: [${data.emergencyType}]`);

    return {
      success: true,
      message: 'Immediate emergency alert & sound siren broadcast dispatched successfully across facility network.',
      incidentId: incident.id,
      timestamp: incident.reportedAt,
      externalDispatchNote: 'System architecture supports municipal automated dispatch hooks (No automatic dialing assumed).',
    };
  }

  async listActiveIncidents(tenantId: string) {
    return this.prisma.incident.findMany({
      where: { tenantId },
      orderBy: { reportedAt: 'desc' },
      include: {
        reporter: { select: { fullName: true, email: true, avatarUrl: true } },
        layout: { select: { name: true, fileUrl: true } },
      },
    });
  }

  async updateIncidentStatus(tenantId: string, actorId: string, incidentId: string, data: ResolveIncidentDto) {
    const incident = await this.prisma.incident.findFirst({
      where: { tenantId, id: incidentId },
    });

    if (!incident) {
      throw new NotFoundException(`Incident [${incidentId}] not located in this workspace.`);
    }

    const updated = await this.prisma.incident.update({
      where: { id: incidentId },
      data: {
        status: data.status as any,
        correctiveActions: data.correctiveActions,
        resolvedAt: data.status === 'RESOLVED' || data.status === 'CLOSED' ? new Date() : undefined,
      },
    });

    await this.prisma.auditLog.create({
      data: {
        tenantId,
        actorId,
        actionType: 'INCIDENT_STATUS_UPDATED',
        targetEntity: 'INCIDENT',
        targetId: incidentId,
        oldValues: { status: incident.status },
        newValues: { status: data.status, actions: data.correctiveActions },
      },
    });

    return updated;
  }
}
