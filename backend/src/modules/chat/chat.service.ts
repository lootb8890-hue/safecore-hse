import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';
import { EmergenciesGateway } from '../emergencies/emergencies.gateway';

export interface SendMessageDto {
  groupId?: string;
  messageType: 'TEXT' | 'IMAGE' | 'FILE' | 'VOICE' | 'VIDEO' | 'LOCATION';
  content?: string;
  attachmentUrl?: string;
  replyToId?: string;
}

@Injectable()
export class ChatService {
  constructor(
    private prisma: PrismaService,
    private gateway: EmergenciesGateway,
  ) {}

  async createGroup(tenantId: string, name: string, description?: string) {
    return this.prisma.chatGroup.create({
      data: { tenantId, name, description },
    });
  }

  async listGroups(tenantId: string) {
    return this.prisma.chatGroup.findMany({
      where: { tenantId },
      orderBy: { createdAt: 'asc' },
    });
  }

  async sendMessage(tenantId: string, senderId: string, data: SendMessageDto) {
    const msg = await this.prisma.chatMessage.create({
      data: {
        tenantId,
        groupId: data.groupId,
        senderId,
        messageType: data.messageType as any,
        content: data.content,
        attachmentUrl: data.attachmentUrl,
        replyToId: data.replyToId,
      },
      include: {
        sender: { select: { id: true, fullName: true, avatarUrl: true, role: true } },
      },
    });

    // Real-Time Socket Broadcast to enterprise workspace room
    this.gateway.broadcastChatMessage(tenantId, {
      ...msg,
      broadcastAt: new Date().toISOString(),
    });

    return msg;
  }

  async listMessages(tenantId: string, groupId?: string, limit = 50) {
    const where: any = { tenantId };
    if (groupId) where.groupId = groupId;

    return this.prisma.chatMessage.findMany({
      where,
      orderBy: { createdAt: 'desc' },
      take: limit,
      include: {
        sender: { select: { id: true, fullName: true, avatarUrl: true, role: true } },
      },
    });
  }

  async togglePinMessage(tenantId: string, messageId: string, pin: boolean) {
    const msg = await this.prisma.chatMessage.findFirst({ where: { tenantId, id: messageId } });
    if (!msg) throw new NotFoundException('Message not found.');

    return this.prisma.chatMessage.update({
      where: { id: messageId },
      data: { isPinned: pin },
    });
  }

  async deleteMessage(tenantId: string, messageId: string) {
    const msg = await this.prisma.chatMessage.findFirst({ where: { tenantId, id: messageId } });
    if (!msg) throw new NotFoundException('Message not found.');

    await this.prisma.chatMessage.delete({ where: { id: messageId } });
    return { success: true, messageId };
  }
}
