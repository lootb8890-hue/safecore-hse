import { Injectable, NotFoundException, ConflictException, Logger } from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';
import * as QRCode from 'qrcode';

export interface CreateAssetDto {
  name: string;
  assetNumber: string;
  layerType: 'EXTINGUISHER' | 'EMERGENCY_EXIT' | 'FIRST_AID' | 'ALARM' | 'ELECTRICAL' | 'HAZARD_ZONE' | 'SAFETY_EQUIPMENT' | 'CAMERA';
  layoutId?: string;
  coordX?: number;
  coordY?: number;
  manufacturer?: string;
  installationDate?: string;
  warrantyExpiry?: string;
}

@Injectable()
export class AssetsService {
  private readonly logger = new Logger(AssetsService.name);

  constructor(private prisma: PrismaService) {}

  async createAsset(tenantId: string, actorId: string, data: CreateAssetDto) {
    const existing = await this.prisma.safetyAsset.findFirst({
      where: { tenantId, assetNumber: data.assetNumber },
    });

    if (existing) {
      throw new ConflictException(`Asset Number [${data.assetNumber}] already exists in this organization.`);
    }

    // Generate unique cryptographic QR Payload & numeric Linear Barcode
    const uniqueId = `ast_${Math.random().toString(36).substring(2, 10)}_${Date.now()}`;
    const qrCodePayload = `safecore://asset?id=${uniqueId}&tenant=${tenantId}`;
    const barcodeNumeric = Math.floor(100000000000 + Math.random() * 900000000000).toString(); // 12-digit EAN style

    // Generate data URL for QR representation
    let qrImageBase64 = '';
    try {
      qrImageBase64 = await QRCode.toDataURL(qrCodePayload, { errorCorrectionLevel: 'H', margin: 1, width: 300 });
    } catch (e) {
      this.logger.error('Failed to encode QR Data URL', e);
    }

    const initialHistory = [
      {
        timestamp: new Date().toISOString(),
        action: 'ASSET_REGISTERED',
        actor: actorId,
        status: 'ACTIVE',
        notes: 'Initial digital twin provisioned with automatic QR & Barcode generation.',
      },
    ];

    const asset = await this.prisma.safetyAsset.create({
      data: {
        id: uniqueId,
        tenantId,
        layoutId: data.layoutId,
        layerType: data.layerType as any,
        assetNumber: data.assetNumber,
        name: data.name,
        qrCode: qrCodePayload,
        barcode: barcodeNumeric,
        status: 'ACTIVE',
        coordX: data.coordX,
        coordY: data.coordY,
        manufacturer: data.manufacturer,
        installationDate: data.installationDate ? new Date(data.installationDate) : new Date(),
        warrantyExpiry: data.warrantyExpiry ? new Date(data.warrantyExpiry) : undefined,
        historyLog: initialHistory,
      },
    });

    // Create immutable audit log
    await this.prisma.auditLog.create({
      data: {
        tenantId,
        actorId,
        actionType: 'ASSET_CREATED',
        targetEntity: 'SAFETY_ASSET',
        targetId: asset.id,
        newValues: { assetNumber: asset.assetNumber, layerType: asset.layerType, qr: asset.qrCode },
      },
    });

    return {
      ...asset,
      qrImageBase64,
      printableLabelEndpoint: `/api/v1/assets/${asset.id}/printable-label`,
    };
  }

  async getAssetById(tenantId: string, id: string) {
    const asset = await this.prisma.safetyAsset.findFirst({
      where: { tenantId, id },
      include: {
        layout: { select: { name: true, fileUrl: true } },
        inspectionRecords: {
          orderBy: { executedAt: 'desc' },
          take: 10,
          include: { inspector: { select: { fullName: true, avatarUrl: true } } },
        },
      },
    });

    if (!asset) {
      throw new NotFoundException(`Safety Asset with identifier [${id}] not located.`);
    }

    return asset;
  }

  async scanAsset(tenantId: string, scanQuery: string) {
    // Lookup by either QR code string or Linear Barcode
    const asset = await this.prisma.safetyAsset.findFirst({
      where: {
        tenantId,
        OR: [{ qrCode: scanQuery }, { barcode: scanQuery }, { id: scanQuery }, { assetNumber: scanQuery }],
      },
      include: {
        inspectionRecords: {
          orderBy: { executedAt: 'desc' },
          take: 5,
          include: { inspector: { select: { fullName: true } } },
        },
      },
    });

    if (!asset) {
      throw new NotFoundException('Scanned code did not match any registered asset in this tenant workspace.');
    }

    return {
      success: true,
      currentStatus: asset.status,
      assetDetails: asset,
      lastInspection: asset.inspectionRecords[0] || null,
      timeline: asset.historyLog,
    };
  }

  async listAssets(tenantId: string, layerType?: string, status?: string) {
    const where: any = { tenantId };
    if (layerType) where.layerType = layerType;
    if (status) where.status = status;

    return this.prisma.safetyAsset.findMany({
      where,
      orderBy: { createdAt: 'desc' },
    });
  }

  async getPrintableLabelPayload(tenantId: string, id: string) {
    const asset = await this.prisma.safetyAsset.findFirst({
      where: { tenantId, id },
      include: { tenant: { select: { name: true, logoUrl: true, primaryColor: true } } },
    });

    if (!asset) {
      throw new NotFoundException('Asset not found for label generation.');
    }

    const qrDataUrl = await QRCode.toDataURL(asset.qrCode, { margin: 1, width: 200 });

    return {
      tenantName: (asset as any).tenant?.name,
      tenantLogo: (asset as any).tenant?.logoUrl,
      assetName: asset.name,
      assetNumber: asset.assetNumber,
      qrCodeDataUrl: qrDataUrl,
      barcodeText: asset.barcode,
      layerType: asset.layerType,
      status: asset.status,
      generatedAt: new Date().toISOString(),
    };
  }
}
