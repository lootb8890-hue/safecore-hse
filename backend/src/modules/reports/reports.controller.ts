import { Controller, Get, UseGuards, Res } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { ReportsService } from './reports.service';
import { RbacGuard } from '../../common/guards/rbac.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';

@ApiTags('Executive Reports, Dashboard KPIs & Data Exports')
@ApiBearerAuth()
@UseGuards(RbacGuard)
@Controller('reports')
export class ReportsController {
  constructor(private readonly reportsService: ReportsService) {}

  @Get('dashboard-kpis')
  @Roles('ADMIN', 'MEMBER')
  @ApiOperation({ summary: 'Retrieve enterprise safety health index score out of 100 & live facility KPI counts' })
  async kpis(@CurrentUser('tenantId') tenantId: string) {
    return this.reportsService.getExecutiveDashboardKpis(tenantId);
  }

  @Get('export-inspections-pdf')
  @Roles('ADMIN', 'MEMBER')
  @ApiOperation({ summary: 'Export formal print-ready PDF corporate compliance inspection audit report' })
  async exportPdf(@CurrentUser('tenantId') tenantId: string) {
    return this.reportsService.exportInspectionsPdfReport(tenantId);
  }

  @Get('export-incidents-csv')
  @Roles('ADMIN', 'MEMBER')
  @ApiOperation({ summary: 'Download complete chronological incident archives in Excel/CSV format' })
  async exportCsv(@CurrentUser('tenantId') tenantId: string, @Res({ passthrough: true }) res: any) {
    const output = await this.reportsService.exportIncidentsExcelCsv(tenantId);
    res.set({
      'Content-Type': output.contentType,
      'Content-Disposition': `attachment; filename="${output.filename}"`,
    });
    return output.data;
  }
}
