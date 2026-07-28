import { Injectable, NestMiddleware, Logger } from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';
import { JwtService } from '@nestjs/jwt';

@Injectable()
export class AuthMiddleware implements NestMiddleware {
  private readonly logger = new Logger('AuthMiddleware');

  constructor(private readonly jwtService: JwtService) {}

  use(req: Request & { user?: any; currentTenantId?: string }, res: Response, next: NextFunction) {
    const authHeader = req.headers.authorization;
    if (authHeader && authHeader.startsWith('Bearer ')) {
      const token = authHeader.split(' ')[1];
      try {
        const secret = process.env.JWT_SECRET || 'SafeCoreEnterpriseJwtSecretKey2026!superSecret!DoNotExposeInProd';
        const decoded = this.jwtService.verify(token, { secret });
        req.user = {
          id: decoded.sub,
          email: decoded.email,
          role: decoded.role,
          tenantId: decoded.tenantId,
        };
        if (decoded.tenantId && !req.headers['x-tenant-id']) {
          req.headers['x-tenant-id'] = decoded.tenantId;
        }
      } catch (error) {
        this.logger.debug(`Token verification silent skip: ${(error as Error).message}`);
      }
    }
    next();
  }
}
