import { Controller, Post, Get, Body, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { InspectionsService, CreateFormDto, SubmitInspectionDto } from './inspections.service';
import { RbacGuard } from '../../common/guards/rbac.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';

@ApiTags('Inspections & No-Code Form Builder')
@ApiBearerAuth()
@UseGuards(RbacGuard)
@Controller('inspections')
export class InspectionsController {
  constructor(private readonly inspectionsService: InspectionsService) {}

  @Post('forms')
  @Roles('ADMIN')
  @ApiOperation({ summary: '(Admin Only) Form Builder: Publish dynamic inspection schema with 14 input field types' })
  @ApiResponse({ status: 201, description: 'Inspection form generated & scheduled.' })
  async createForm(
    @CurrentUser('tenantId') tenantId: string,
    @CurrentUser('id') actorId: string,
    @Body() body: CreateFormDto,
  ) {
    return this.inspectionsService.createForm(tenantId, actorId, body);
  }

  @Get('forms')
  @Roles('ADMIN', 'MEMBER')
  @ApiOperation({ summary: 'Retrieve available inspection forms filtered by target layout layer' })
  @ApiQuery({ name: 'targetLayer', required: false, description: 'EXTINGUISHER, CAMERA, ALARM, etc.' })
  async listForms(@CurrentUser('tenantId') tenantId: string, @Query('targetLayer') targetLayer?: string) {
    return this.inspectionsService.listForms(tenantId, targetLayer);
  }

  @Post('execute')
  @Roles('ADMIN', 'MEMBER')
  @ApiOperation({ summary: 'Submit completed field inspection check with GPS coordinate & digital signature' })
  @ApiResponse({ status: 201, description: 'Inspection recorded; linked asset next inspection date rescheduled automatically.' })
  async execute(
    @CurrentUser('tenantId') tenantId: string,
    @CurrentUser('id') inspectorId: string,
    @Body() body: SubmitInspectionDto,
  ) {
    return this.inspectionsService.submitInspection(tenantId, inspectorId, body);
  }

  @Get('records')
  @Roles('ADMIN', 'MEMBER')
  @ApiOperation({ summary: 'View chronological audit records of executed field inspections' })
  @ApiQuery({ name: 'assetId', required: false })
  @ApiQuery({ name: 'inspectorId', required: false })
  async listRecords(
    @CurrentUser('tenantId') tenantId: string,
    @Query('assetId') assetId?: string,
    @Query('inspectorId') inspectorId?: string,
  ) {
    return this.inspectionsService.listRecords(tenantId, assetId, inspectorId);
  }
}
