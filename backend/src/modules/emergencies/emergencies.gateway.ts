import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  OnGatewayConnection,
  OnGatewayDisconnect,
  MessageBody,
  ConnectedSocket,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { Logger } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';

@WebSocketGateway({
  namespace: '/hse',
  cors: { origin: '*', credentials: true },
})
export class EmergenciesGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: Server;

  private readonly logger = new Logger('SafeCoreRealtimeGateway');

  constructor(private readonly jwtService: JwtService) {}

  async handleConnection(client: Socket) {
    try {
      const token = client.handshake.query.token as string || client.handshake.headers.authorization?.split(' ')[1];
      if (!token) {
        this.logger.warn(`Rejected unauthenticated WebSocket handshake from socket: ${client.id}`);
        client.disconnect();
        return;
      }
      
      const payload = this.jwtService.verify(token, {
        secret: process.env.JWT_SECRET || 'SafeCoreEnterpriseJwtSecretKey2026!superSecret!DoNotExposeInProd',
      });

      const tenantRoom = `tenant_${payload.tenantId}`;
      client.join(tenantRoom);
      client.data.user = payload;

      this.logger.log(`📱 Socket client [${client.id}] joined tenant broadcast room [${tenantRoom}] - Role: ${payload.role}`);
    } catch (error) {
      this.logger.error(`WebSocket Token Verification Failed for socket: ${client.id}`, error);
      client.disconnect();
    }
  }

  handleDisconnect(client: Socket) {
    this.logger.log(`🔌 Socket client disconnected: ${client.id}`);
  }

  /**
   * Broadcasts high-priority zero-latency red alarm sirens to all online safety team devices
   * within the target tenant workspace room.
   */
  broadcastEmergencySiren(tenantId: string, alertPayload: any) {
    const room = `tenant_${tenantId}`;
    this.logger.warn(`🚨 DISPATCHING IMMEDIATE EMERGENCY SIREN TO ROOM [${room}]: Type = ${alertPayload.type}`);
    this.server.to(room).emit('EMERGENCY_SIREN_TRIGGERED', {
      ...alertPayload,
      serverBroadcastTimestamp: new Date().toISOString(),
    });
  }

  /**
   * Broadcasts real-time internal team chat discussions and attachment uploads
   */
  broadcastChatMessage(tenantId: string, messagePayload: any) {
    const room = `tenant_${tenantId}`;
    this.server.to(room).emit('CHAT_MESSAGE_RECEIVED', messagePayload);
  }

  @SubscribeMessage('ping_heartbeat')
  handlePing(@ConnectedSocket() client: Socket): string {
    return `pong_${client.id}_${Date.now()}`;
  }
}
