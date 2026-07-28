import { Injectable, NotFoundException, Logger } from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';

export interface CreateLayoutDto {
  name: string;
  branchName?: string;
  fileUrl: string;
  fileType: 'PDF' | 'PNG' | 'JPG' | 'DWG' | 'SVG';
  widthMeters?: number;
  heightMeters?: number;
  canvasResX?: number;
  canvasResY?: number;
}

export interface UpdateAssetPinDto {
  assetId: string;
  coordX: number;
  coordY: number;
}

@Injectable()
export class LayoutsService {
  private readonly logger = new Logger(LayoutsService.name);

  constructor(private prisma: PrismaService) {}

  async createLayout(tenantId: string, actorId: string, data: CreateLayoutDto) {
    const layout = await this.prisma.facilityLayout.create({
      data: {
        tenantId,
        name: data.name,
        branchName: data.branchName,
        fileUrl: data.fileUrl,
        fileType: data.fileType,
        widthMeters: data.widthMeters || 100.0,
        heightMeters: data.heightMeters || 100.0,
        canvasResX: data.canvasResX || 3000,
        canvasResY: data.canvasResY || 3000,
      },
    });

    await this.prisma.auditLog.create({
      data: {
        tenantId,
        actorId,
        actionType: 'FACILITY_LAYOUT_UPLOADED',
        targetEntity: 'FACILITY_LAYOUT',
        targetId: layout.id,
        newValues: { name: layout.name, fileType: layout.fileType, fileUrl: layout.fileUrl },
      },
    });

    return layout;
  }

  async getLayoutWithLayers(tenantId: string, id: string, layerFilter?: string[]) {
    const layout = await this.prisma.facilityLayout.findFirst({
      where: { tenantId, id },
    });

    if (!layout) {
      throw new NotFoundException(`Facility floor plan with ID [${id}] not located.`);
    }

    // Prepare layer filter query for digital twins pinned on this blueprint
    const assetWhere: any = { tenantId, layoutId: id };
    if (layerFilter && layerFilter.length > 0 && layerFilter[0] !== 'ALL') {
      assetWhere.layerType = { in: layerFilter as any };
    }

    const pinnedAssets = await this.prisma.safetyAsset.findMany({
      where: assetWhere,
      select: {
        id: true,
        assetNumber: true,
        name: true,
        layerType: true,
        status: true,
        coordX: true,
        coordY: true,
        qrCode: true,
      },
    });

    // Group assets by layer type for rapid UI legend stats and rendering
    const layerStatistics = {
      EXTINGUISHER: pinnedAssets.filter((a) => a.layerType === 'EXTINGUISHER').length,
      EMERGENCY_EXIT: pinnedAssets.filter((a) => a.layerType === 'EMERGENCY_EXIT').length,
      FIRST_AID: pinnedAssets.filter((a) => a.layerType === 'FIRST_AID').length,
      ALARM: pinnedAssets.filter((a) => a.layerType === 'ALARM').length,
      ELECTRICAL: pinnedAssets.filter((a) => a.layerType === 'ELECTRICAL').length,
      HAZARD_ZONE: pinnedAssets.filter((a) => a.layerType === 'HAZARD_ZONE').length,
      SAFETY_EQUIPMENT: pinnedAssets.filter((a) => a.layerType === 'SAFETY_EQUIPMENT').length,
      CAMERA: pinnedAssets.filter((a) => a.layerType === 'CAMERA').length,
    };

    return {
      canvas: layout,
      pinnedAssets,
      layerStatistics,
    };
  }

  async listLayouts(tenantId: string) {
    return this.prisma.facilityLayout.findMany({
      where: { tenantId },
      orderBy: { createdAt: 'desc' },
      include: {
        _count: { select: { safetyAssets: true, incidents: true } },
      },
    });
  }

  async updatePinCoordinates(tenantId: string, actorId: string, layoutId: string, data: UpdateAssetPinDto) {
    const asset = await this.prisma.safetyAsset.findFirst({
      where: { tenantId, id: data.assetId },
    });

    if (!asset) {
      throw new NotFoundException(`Asset [${data.assetId}] not found in workspace.`);
    }

    const updated = await this.prisma.safetyAsset.update({
      where: { id: data.assetId },
      data: {
        layoutId: layoutId,
        coordX: data.coordX,
        coordY: data.coordY,
      },
    });

    await this.prisma.auditLog.create({
      data: {
        tenantId,
        actorId,
        actionType: 'ASSET_PIN_REPOSITIONED',
        targetEntity: 'SAFETY_ASSET',
        targetId: updated.id,
        newValues: { layoutId, x: data.coordX, y: data.coordY },
      },
    });

    return { success: true, updated };
  }
}
