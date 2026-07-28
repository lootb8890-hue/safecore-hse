import { Controller, Post, Get, Put, Body, Param, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { EmergenciesService, TriggerEmergencyDto, ResolveIncidentDto } from './emergencies.service';
import { RbacGuard } from '../../common/guards/rbac.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';

@ApiTags('Emergency Center & Instant Alert Siren')
@ApiBearerAuth()
@UseGuards(RbacGuard)
@Controller('emergencies')
export class EmergenciesController {
  constructor(private readonly emergenciesService: EmergenciesService) {}

  @Post('trigger')
  @Roles('ADMIN', 'MEMBER')
  @ApiOperation({ summary: 'RED SIREN TRIGGER: Instantly broadcast real-time audible emergency alarm to all staff' })
  @ApiResponse({ status: 201, description: 'Siren broadcast dispatched via WebSockets; incident logged.' })
  async trigger(
    @CurrentUser('tenantId') tenantId: string,
    @CurrentUser('id') reporterId: string,
    @Body() body: TriggerEmergencyDto,
  ) {
    return this.emergenciesService.triggerEmergency(tenantId, reporterId, body);
  }

  @Get('incidents')
  @Roles('ADMIN', 'MEMBER')
  @ApiOperation({ summary: 'List active emergency incident logs and ongoing alarm investigations' })
  async list(@CurrentUser('tenantId') tenantId: string) {
    return this.emergenciesService.listActiveIncidents(tenantId);
  }

  @Put('incidents/:id/resolve')
  @Roles('ADMIN')
  @ApiOperation({ summary: '(Admin Only) Document corrective actions taken and close emergency incident alarm' })
  async resolve(
    @CurrentUser('tenantId') tenantId: string,
    @CurrentUser('id') actorId: string,
    @Param('id') id: string,
    @Body() body: ResolveIncidentDto,
  ) {
    return this.emergenciesService.updateIncidentStatus(tenantId, actorId, id, body);
  }
}
