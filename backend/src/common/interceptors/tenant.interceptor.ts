import {
  Injectable,
  NestInterceptor,
  ExecutionContext,
  CallHandler,
  UnauthorizedException,
  Logger,
} from '@nestjs/common';
import { Observable } from 'rxjs';

@Injectable()
export class TenantInterceptor implements NestInterceptor {
  private readonly logger = new Logger('TenantIsolationInterceptor');

  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const request = context.switchToHttp().getRequest();
    
    // Extract tenant identifier from authenticated JWT token or trusted header
    const userTenantId = request.user?.tenantId;
    const headerTenantId = request.headers['x-tenant-id'] as string;

    const effectiveTenantId = userTenantId || headerTenantId;

    if (!effectiveTenantId && !request.url.includes('/api/v1/auth')) {
      this.logger.warn(`Rejected unauthorized multi-tenant access attempted on path: ${request.url}`);
      throw new UnauthorizedException(
        'Tenant Isolation Verification Failed: Missing valid Tenant Context (X-Tenant-ID or JWT claim).',
      );
    }

    // Attach verified tenantId to request object for downstream repository enforcement
    request.currentTenantId = effectiveTenantId;
    return next.handle();
  }
}
