import { Controller, Get, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { AuditService } from './audit.service';
import { RbacGuard } from '../../common/guards/rbac.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';

@ApiTags('Immutable Audit Log System (Compliance)')
@ApiBearerAuth()
@UseGuards(RbacGuard)
@Controller('audit-logs')
export class AuditController {
  constructor(private readonly auditService: AuditService) {}

  @Get()
  @Roles('ADMIN', 'MEMBER')
  @ApiOperation({
    summary: 'Retrieve tamper-proof chronological audit trail (Who, When, What Changed - Deletes strictly forbidden)',
  })
  @ApiQuery({ name: 'limit', required: false, type: Number, description: 'Number of records to return (default 100)' })
  @ApiQuery({ name: 'entity', required: false, description: 'Filter by entity: USER, ASSET, INCIDENT, TASK, etc.' })
  async list(
    @CurrentUser('tenantId') tenantId: string,
    @Query('limit') limit?: number,
    @Query('entity') entity?: string,
  ) {
    return this.auditService.listLogs(tenantId, limit || 100, entity);
  }
}
