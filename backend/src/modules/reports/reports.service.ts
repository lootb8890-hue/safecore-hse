import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';

@Injectable()
export class ReportsService {
  constructor(private prisma: PrismaService) {}

  async getExecutiveDashboardKpis(tenantId: string) {
    const totalAssets = await this.prisma.safetyAsset.count({ where: { tenantId } });
    const activeAlarms = await this.prisma.incident.count({ where: { tenantId, status: 'ACTIVE_ALARM' } });
    const resolvedIncidents = await this.prisma.incident.count({ where: { tenantId, status: { in: ['RESOLVED', 'CLOSED'] } } });
    const completedInspections = await this.prisma.inspectionRecord.count({ where: { tenantId, status: 'COMPLETED' } });

    // Calculate dynamic corporate safety health score out of 100%
    let safetyScore = 96.5;
    if (activeAlarms > 0) safetyScore -= activeAlarms * 5.0;
    if (safetyScore < 40) safetyScore = 40; // Floor threshold

    return {
      safetyHealthScore: parseFloat(safetyScore.toFixed(1)),
      complianceGrade: safetyScore >= 90 ? 'A+ (Exemplary)' : safetyScore >= 75 ? 'B (Satisfactory)' : 'C (Action Required)',
      kpiSummary: {
        totalRegisteredAssets: totalAssets,
        activeEmergencyAlarms: activeAlarms,
        resolvedIncidentCases: resolvedIncidents,
        completedSafetyInspections: completedInspections,
      },
      generatedAt: new Date().toISOString(),
    };
  }

  async exportInspectionsPdfReport(tenantId: string) {
    const tenant = await this.prisma.tenant.findUnique({ where: { id: tenantId } });
    const records = await this.prisma.inspectionRecord.findMany({
      where: { tenantId },
      include: {
        form: { select: { title: true, scheduleFrequency: true } },
        inspector: { select: { fullName: true, department: true } },
        asset: { select: { assetNumber: true, name: true } },
      },
      orderBy: { executedAt: 'desc' },
      take: 100,
    });

    return {
      reportType: 'CORPORATE_INSPECTION_AUDIT_REPORT',
      enterpriseBranding: {
        organizationName: tenant?.name,
        logo: tenant?.logoUrl,
        primaryThemeColor: tenant?.primaryColor,
      },
      exportFormat: 'PDF_PRINT_READY',
      totalRecords: records.length,
      tableData: records.map((r) => ({
        inspectionId: r.id,
        date: r.executedAt,
        formTitle: (r as any).form?.title,
        targetAsset: `${(r as any).asset?.name || 'N/A'} (#${(r as any).asset?.assetNumber || 'N/A'})`,
        inspectorName: (r as any).inspector?.fullName,
        resultStatus: r.status,
        gpsVerified: r.gpsLatitude && r.gpsLongitude ? `Lat: ${r.gpsLatitude}, Lng: ${r.gpsLongitude}` : 'Manual Verification',
      })),
    };
  }

  async exportIncidentsExcelCsv(tenantId: string) {
    const incidents = await this.prisma.incident.findMany({
      where: { tenantId },
      include: { reporter: { select: { fullName: true, email: true } } },
      orderBy: { reportedAt: 'desc' },
    });

    // Generate strict CSV formatted text stream
    const headers = 'ID,Type,Severity,Status,LocationText,Reporter,ReportedAt,ResolvedAt,CorrectiveActions\n';
    const rows = incidents
      .map((i) =>
        [
          `"${i.id}"`,
          `"${i.emergencyType}"`,
          `"${i.severity}"`,
          `"${i.status}"`,
          `"${i.locationText.replace(/"/g, '""')}"`,
          `"${(i as any).reporter?.fullName || 'N/A'}"`,
          `"${i.reportedAt.toISOString()}"`,
          `"${i.resolvedAt ? i.resolvedAt.toISOString() : 'PENDING'}"`,
          `"${(i.correctiveActions || '').replace(/"/g, '""')}"`,
        ].join(','),
      )
      .join('\n');

    return {
      filename: `SafeCore_Incidents_Export_${Date.now()}.csv`,
      contentType: 'text/csv',
      data: headers + rows,
    };
  }
}
