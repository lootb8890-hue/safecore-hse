import { Controller, Post, Get, Put, Delete, Body, Param, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { ChatService, SendMessageDto } from './chat.service';
import { RbacGuard } from '../../common/guards/rbac.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';

@ApiTags('Internal Real-time Chat & Groups')
@ApiBearerAuth()
@UseGuards(RbacGuard)
@Controller('chat')
export class ChatController {
  constructor(private readonly chatService: ChatService) {}

  @Post('groups')
  @Roles('ADMIN', 'MEMBER')
  @ApiOperation({ summary: 'Create a dedicated team communication group channel' })
  async createGroup(@CurrentUser('tenantId') tenantId: string, @Body() body: { name: string; description?: string }) {
    return this.chatService.createGroup(tenantId, body.name, body.description);
  }

  @Get('groups')
  @Roles('ADMIN', 'MEMBER')
  @ApiOperation({ summary: 'List available workspace communication groups' })
  async listGroups(@CurrentUser('tenantId') tenantId: string) {
    return this.chatService.listGroups(tenantId);
  }

  @Post('messages')
  @Roles('ADMIN', 'MEMBER')
  @ApiOperation({ summary: 'Send real-time chat message (Text, Image, PDF, Voice Note, Video, GPS Location)' })
  @ApiResponse({ status: 201, description: 'Message saved & broadcast via Socket.io.' })
  async send(
    @CurrentUser('tenantId') tenantId: string,
    @CurrentUser('id') senderId: string,
    @Body() body: SendMessageDto,
  ) {
    return this.chatService.sendMessage(tenantId, senderId, body);
  }

  @Get('messages')
  @Roles('ADMIN', 'MEMBER')
  @ApiOperation({ summary: 'Retrieve channel discussion messages with rich attachment urls' })
  @ApiQuery({ name: 'groupId', required: false })
  async listMessages(@CurrentUser('tenantId') tenantId: string, @Query('groupId') groupId?: string) {
    return this.chatService.listMessages(tenantId, groupId);
  }

  @Put('messages/:id/pin')
  @Roles('ADMIN', 'MEMBER')
  @ApiOperation({ summary: 'Pin or unpin an important safety instruction message in channel' })
  async pin(@CurrentUser('tenantId') tenantId: string, @Param('id') id: string, @Body('isPinned') isPinned: boolean) {
    return this.chatService.togglePinMessage(tenantId, id, isPinned);
  }

  @Delete('messages/:id')
  @Roles('ADMIN', 'MEMBER')
  @ApiOperation({ summary: 'Remove an incorrect chat message from feed' })
  async delete(@CurrentUser('tenantId') tenantId: string, @Param('id') id: string) {
    return this.chatService.deleteMessage(tenantId, id);
  }
}
