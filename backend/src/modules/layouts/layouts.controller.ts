import { Controller, Post, Get, Put, Body, Param, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { LayoutsService, CreateLayoutDto, UpdateAssetPinDto } from './layouts.service';
import { RbacGuard } from '../../common/guards/rbac.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';

@ApiTags('Interactive Company Layouts')
@ApiBearerAuth()
@UseGuards(RbacGuard)
@Controller('layouts')
export class LayoutsController {
  constructor(private readonly layoutsService: LayoutsService) {}

  @Post()
  @Roles('ADMIN')
  @ApiOperation({ summary: '(Admin Only) Upload a building floor plan or engineering blueprint (PDF/DWG/PNG)' })
  @ApiResponse({ status: 201, description: 'Floor plan canvas registered and optimized.' })
  async upload(
    @CurrentUser('tenantId') tenantId: string,
    @CurrentUser('id') actorId: string,
    @Body() body: CreateLayoutDto,
  ) {
    return this.layoutsService.createLayout(tenantId, actorId, body);
  }

  @Get()
  @Roles('ADMIN', 'MEMBER')
  @ApiOperation({ summary: 'List available facility floor plan canvases with asset placement counts' })
  async list(@CurrentUser('tenantId') tenantId: string) {
    return this.layoutsService.listLayouts(tenantId);
  }

  @Get(':id/canvas')
  @Roles('ADMIN', 'MEMBER')
  @ApiOperation({ summary: 'Retrieve interactive viewport dimensions & layer-filtered pin placements' })
  @ApiQuery({ name: 'layers', required: false, description: 'Comma-separated layer types (e.g., EXTINGUISHER,CAMERA)' })
  async getCanvas(
    @CurrentUser('tenantId') tenantId: string,
    @Param('id') id: string,
    @Query('layers') layers?: string,
  ) {
    const layerFilter = layers ? layers.split(',').map((l) => l.trim()) : ['ALL'];
    return this.layoutsService.getLayoutWithLayers(tenantId, id, layerFilter);
  }

  @Put(':id/pins')
  @Roles('ADMIN', 'MEMBER')
  @ApiOperation({ summary: 'Reposition or add a safety asset digital pin coordinate (X, Y) onto the canvas' })
  async updatePin(
    @CurrentUser('tenantId') tenantId: string,
    @CurrentUser('id') actorId: string,
    @Param('id') id: string,
    @Body() body: UpdateAssetPinDto,
  ) {
    return this.layoutsService.updatePinCoordinates(tenantId, actorId, id, body);
  }
}
