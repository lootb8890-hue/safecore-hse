import { Module } from '@nestjs/common';
import { ChatService } from './chat.service';
import { ChatController } from './chat.controller';
import { PrismaService } from '../../common/prisma/prisma.service';
import { EmergenciesModule } from '../emergencies/emergencies.module';

@Module({
  imports: [EmergenciesModule],
  controllers: [ChatController],
  providers: [ChatService, PrismaService],
  exports: [ChatService],
})
export class ChatModule {}
