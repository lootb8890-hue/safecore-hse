import { Injectable, NotFoundException, BadRequestException, Logger } from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';

export interface FormFieldSchema {
  id: string;
  label: string;
  type: 'TEXT' | 'NUMBER' | 'CHECKBOX' | 'DROPDOWN' | 'IMAGE_UPLOAD' | 'CAMERA_CAPTURE' | 'SIGNATURE' | 'DATE' | 'TIME' | 'GPS_CAPTURE' | 'QR_SCANNER' | 'BARCODE_SCANNER' | 'FILE_ATTACHMENT' | 'RATING_1_TO_5';
  required?: boolean;
  options?: string[]; // For dropdowns or ratings
  defaultValue?: any;
}

export interface CreateFormDto {
  title: string;
  description?: string;
  targetLayer?: string;
  scheduleFrequency: 'DAILY' | 'WEEKLY' | 'MONTHLY' | 'QUARTERLY' | 'BIANNUAL' | 'ANNUAL' | 'ON_DEMAND';
  fields: FormFieldSchema[];
}

export interface SubmitInspectionDto {
  formId: string;
  assetId?: string;
  status: 'COMPLETED' | 'FAILED_WITH_REMARKS' | 'DRAFT_OFFLINE';
  answers: Record<string, any>; // Keyed by field id
  signatureUrl?: string;
  gpsLatitude?: number;
  gpsLongitude?: number;
  clientTimestamp?: string;
}

@Injectable()
export class InspectionsService {
  private readonly logger = new Logger(InspectionsService.name);

  constructor(private prisma: PrismaService) {}

  async createForm(tenantId: string, actorId: string, data: CreateFormDto) {
    if (!data.fields || data.fields.length === 0) {
      throw new BadRequestException('An inspection form schema must define at least one input element.');
    }

    const form = await this.prisma.inspectionForm.create({
      data: {
        tenantId,
        title: data.title,
        description: data.description,
        targetLayer: data.targetLayer as any,
        scheduleFrequency: data.scheduleFrequency as any,
        formSchema: data.fields as any,
        isActive: true,
      },
    });

    await this.prisma.auditLog.create({
      data: {
        tenantId,
        actorId,
        actionType: 'INSPECTION_FORM_CREATED',
        targetEntity: 'INSPECTION_FORM',
        targetId: form.id,
        newValues: { title: form.title, frequency: form.scheduleFrequency, fieldsCount: data.fields.length },
      },
    });

    return form;
  }

  async listForms(tenantId: string, targetLayer?: string) {
    const where: any = { tenantId, isActive: true };
    if (targetLayer) where.targetLayer = targetLayer;

    return this.prisma.inspectionForm.findMany({
      where,
      orderBy: { createdAt: 'desc' },
    });
  }

  async submitInspection(tenantId: string, inspectorId: string, data: SubmitInspectionDto) {
    const form = await this.prisma.inspectionForm.findFirst({
      where: { tenantId, id: data.formId },
    });

    if (!form) {
      throw new NotFoundException(`Inspection Form template [${data.formId}] does not exist.`);
    }

    const record = await this.prisma.inspectionRecord.create({
      data: {
        tenantId,
        formId: data.formId,
        assetId: data.assetId,
        inspectorId,
        status: data.status as any,
        answers: data.answers as any,
        signatureUrl: data.signatureUrl,
        gpsLatitude: data.gpsLatitude,
        gpsLongitude: data.gpsLongitude,
        executedAt: data.clientTimestamp ? new Date(data.clientTimestamp) : new Date(),
      },
    });

    // If linked to a digital asset, update its inspection lifecycle timestamps automatically
    if (data.assetId && data.status === 'COMPLETED') {
      const executedDate = new Date();
      let nextDate = new Date();

      switch (form.scheduleFrequency) {
        case 'DAILY':
          nextDate.setDate(nextDate.getDate() + 1);
          break;
        case 'WEEKLY':
          nextDate.setDate(nextDate.getDate() + 7);
          break;
        case 'MONTHLY':
          nextDate.setMonth(nextDate.getMonth() + 1);
          break;
        case 'QUARTERLY':
          nextDate.setMonth(nextDate.getMonth() + 3);
          break;
        case 'BIANNUAL':
          nextDate.setMonth(nextDate.getMonth() + 6);
          break;
        case 'ANNUAL':
          nextDate.setFullYear(nextDate.getFullYear() + 1);
          break;
      }

      await this.prisma.safetyAsset.update({
        where: { id: data.assetId },
        data: {
          lastInspection: executedDate,
          nextInspection: form.scheduleFrequency !== 'ON_DEMAND' ? nextDate : undefined,
          status: 'ACTIVE',
        },
      });
    }

    await this.prisma.auditLog.create({
      data: {
        tenantId,
        actorId: inspectorId,
        actionType: 'INSPECTION_EXECUTED',
        targetEntity: 'INSPECTION_RECORD',
        targetId: record.id,
        newValues: { formId: data.formId, assetId: data.assetId, status: data.status },
      },
    });

    return { success: true, recordId: record.id, timestamp: record.executedAt };
  }

  async listRecords(tenantId: string, assetId?: string, inspectorId?: string) {
    const where: any = { tenantId };
    if (assetId) where.assetId = assetId;
    if (inspectorId) where.inspectorId = inspectorId;

    return this.prisma.inspectionRecord.findMany({
      where,
      orderBy: { executedAt: 'desc' },
      include: {
        form: { select: { title: true, scheduleFrequency: true } },
        inspector: { select: { fullName: true, email: true } },
        asset: { select: { assetNumber: true, name: true } },
      },
    });
  }
}
