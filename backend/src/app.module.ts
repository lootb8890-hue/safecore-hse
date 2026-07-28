import { Module, NestModule, MiddlewareConsumer } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { APP_INTERCEPTOR, APP_GUARD } from '@nestjs/core';
import { PrismaService } from './common/prisma/prisma.service';
import { TenantInterceptor } from './common/interceptors/tenant.interceptor';
import { RbacGuard } from './common/guards/rbac.guard';
import { AuthMiddleware } from './common/middleware/auth.middleware';

// Enterprise Multi-Tenant Modular Architecture Imports
import { TenantsModule } from './modules/tenants/tenants.module';
import { AuthModule } from './modules/auth/auth.module';
import { UsersModule } from './modules/users/users.module';
import { AssetsModule } from './modules/assets/assets.module';
import { LayoutsModule } from './modules/layouts/layouts.module';
import { InspectionsModule } from './modules/inspections/inspections.module';
import { EmergenciesModule } from './modules/emergencies/emergencies.module';
import { TasksModule } from './modules/tasks/tasks.module';
import { DocumentsModule } from './modules/documents/documents.module';
import { ChatModule } from './modules/chat/chat.module';
import { AuditModule } from './modules/audit/audit.module';
import { AiModule } from './modules/ai/ai.module';
import { ReportsModule } from './modules/reports/reports.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    TenantsModule,
    AuthModule,
    UsersModule,
    AssetsModule,
    LayoutsModule,
    InspectionsModule,
    EmergenciesModule,
    TasksModule,
    DocumentsModule,
    ChatModule,
    AuditModule,
    AiModule,
    ReportsModule,
  ],
  providers: [
    PrismaService,
    {
      provide: APP_INTERCEPTOR,
      useClass: TenantInterceptor,
    },
    {
      provide: APP_GUARD,
      useClass: RbacGuard,
    },
  ],
})
export class AppModule implements NestModule {
  configure(consumer: MiddlewareConsumer) {
    consumer.apply(AuthMiddleware).forRoutes('*');
  }
}
