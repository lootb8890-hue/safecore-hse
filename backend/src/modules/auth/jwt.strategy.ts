import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { PrismaService } from '../../common/prisma/prisma.service';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(private readonly prisma: PrismaService) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: process.env.JWT_SECRET || 'SafeCoreEnterpriseJwtSecretKey2026!superSecret!DoNotExposeInProd',
    });
  }

  async validate(payload: any) {
    if (!payload || !payload.sub) {
      throw new UnauthorizedException('Invalid cryptographic token authorization.');
    }

    // Verify user activity in database
    const user = await this.prisma.user.findUnique({
      where: { id: payload.sub },
    });

    if (!user || !user.isActive) {
      throw new UnauthorizedException('User session is terminated or inactive inside this Enterprise.');
    }

    // Return profile to be injected into req.user
    return {
      id: user.id,
      email: user.email,
      role: user.role,
      fullName: user.fullName,
      tenantId: user.tenantId,
      department: user.department,
      branch: user.branch,
    };
  }
}
