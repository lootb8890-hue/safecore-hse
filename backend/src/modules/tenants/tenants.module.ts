import { Module } from '@nestjs/common';
import { TenantsService } from './tenants.service';
import { TenantsController } from './tenants.controller';
import { PrismaService } from '../../common/prisma/prisma.service';

@Module({
  controllers: [TenantsController],
  providers: [TenantsService, PrismaService],
  exports: [TenantsService],
})
export class TenantsModule {}
