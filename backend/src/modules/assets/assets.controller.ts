import { Controller, Post, Get, Body, Param, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { AssetsService, CreateAssetDto } from './assets.service';
import { RbacGuard } from '../../common/guards/rbac.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';

@ApiTags('Digital Safety Assets & QR Labels')
@ApiBearerAuth()
@UseGuards(RbacGuard)
@Controller('assets')
export class AssetsController {
  constructor(private readonly assetsService: AssetsService) {}

  @Post()
  @Roles('ADMIN', 'MEMBER')
  @ApiOperation({ summary: 'Register a Digital Safety Asset twin with automated QR & Barcode sticker creation' })
  @ApiResponse({ status: 201, description: 'Asset registered, QR generated.' })
  async create(
    @CurrentUser('tenantId') tenantId: string,
    @CurrentUser('id') actorId: string,
    @Body() body: CreateAssetDto,
  ) {
    return this.assetsService.createAsset(tenantId, actorId, body);
  }

  @Get()
  @Roles('ADMIN', 'MEMBER')
  @ApiOperation({ summary: 'List tenant safety assets filtered by layout layer type or working condition' })
  @ApiQuery({ name: 'layerType', required: false, description: 'Filter by EXTINGUISHER, CAMERA, ALARM, etc.' })
  @ApiQuery({ name: 'status', required: false })
  async list(
    @CurrentUser('tenantId') tenantId: string,
    @Query('layerType') layerType?: string,
    @Query('status') status?: string,
  ) {
    return this.assetsService.listAssets(tenantId, layerType, status);
  }

  @Get('scan')
  @Roles('ADMIN', 'MEMBER')
  @ApiOperation({ summary: 'Instant QR or Barcode scanner endpoint returning asset lifecycle & recent inspections' })
  @ApiQuery({ name: 'code', required: true, description: 'Scanned QR URL payload or linear Barcode integer' })
  async scan(@CurrentUser('tenantId') tenantId: string, @Query('code') code: string) {
    return this.assetsService.scanAsset(tenantId, code);
  }

  @Get(':id')
  @Roles('ADMIN', 'MEMBER')
  @ApiOperation({ summary: 'Retrieve full asset details, inspection timeline history and layout placement' })
  async getDetails(@CurrentUser('tenantId') tenantId: string, @Param('id') id: string) {
    return this.assetsService.getAssetById(tenantId, id);
  }

  @Get(':id/printable-label')
  @Roles('ADMIN', 'MEMBER')
  @ApiOperation({ summary: 'Export ready-to-print industrial adhesive label payload with Logo, QR & Barcode' })
  async getPrintableLabel(@CurrentUser('tenantId') tenantId: string, @Param('id') id: string) {
    return this.assetsService.getPrintableLabelPayload(tenantId, id);
  }
}
