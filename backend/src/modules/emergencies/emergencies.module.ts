import { Module } from '@nestjs/common';
import { EmergenciesService } from './emergencies.service';
import { EmergenciesController } from './emergencies.controller';
import { EmergenciesGateway } from './emergencies.gateway';
import { PrismaService } from '../../common/prisma/prisma.service';
import { AuthModule } from '../auth/auth.module';

@Module({
  imports: [AuthModule],
  controllers: [EmergenciesController],
  providers: [EmergenciesService, EmergenciesGateway, PrismaService],
  exports: [EmergenciesService, EmergenciesGateway],
})
export class EmergenciesModule {}
