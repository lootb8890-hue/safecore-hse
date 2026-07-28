import { Module } from '@nestjs/common';
import { LayoutsService } from './layouts.service';
import { LayoutsController } from './layouts.controller';
import { PrismaService } from '../../common/prisma/prisma.service';

@Module({
  controllers: [LayoutsController],
  providers: [LayoutsService, PrismaService],
  exports: [LayoutsService],
})
export class LayoutsModule {}
