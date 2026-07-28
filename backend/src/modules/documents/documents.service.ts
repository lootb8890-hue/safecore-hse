import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';

export interface UploadDocumentDto {
  title: string;
  category: 'SAFETY_POLICY' | 'SOP' | 'MSDS' | 'REPORT' | 'TRAINING';
  fileUrl: string;
  fileType: string; // PDF, DOCX, XLSX, PNG, MP4
}

@Injectable()
export class DocumentsService {
  constructor(private prisma: PrismaService) {}

  async uploadDocument(tenantId: string, uploaderId: string, data: UploadDocumentDto) {
    const doc = await this.prisma.document.create({
      data: {
        tenantId,
        title: data.title,
        category: data.category as any,
        fileUrl: data.fileUrl,
        fileType: data.fileType.toUpperCase(),
        uploadedById: uploaderId,
      },
    });

    await this.prisma.auditLog.create({
      data: {
        tenantId,
        actorId: uploaderId,
        actionType: 'SAFETY_DOCUMENT_UPLOADED',
        targetEntity: 'DOCUMENT',
        targetId: doc.id,
        newValues: { title: doc.title, category: doc.category, fileType: doc.fileType },
      },
    });

    return doc;
  }

  async listDocuments(tenantId: string, category?: string, searchQuery?: string) {
    const where: any = { tenantId };
    if (category && category !== 'ALL') {
      where.category = category;
    }
    if (searchQuery) {
      where.title = { contains: searchQuery, mode: 'insensitive' };
    }

    return this.prisma.document.findMany({
      where,
      orderBy: { uploadedAt: 'desc' },
      include: {
        uploadedBy: { select: { fullName: true, department: true } },
      },
    });
  }

  async deleteDocument(tenantId: string, actorId: string, id: string) {
    const doc = await this.prisma.document.findFirst({ where: { tenantId, id } });
    if (!doc) {
      throw new NotFoundException('Document not found in tenant repository.');
    }

    await this.prisma.document.delete({ where: { id } });

    await this.prisma.auditLog.create({
      data: {
        tenantId,
        actorId,
        actionType: 'SAFETY_DOCUMENT_DELETED',
        targetEntity: 'DOCUMENT',
        targetId: id,
        oldValues: { title: doc.title, category: doc.category },
      },
    });

    return { success: true, message: 'Document removed from repository.' };
  }
}
