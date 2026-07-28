import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';

export interface CreateTenantDto {
  name: string;
  subdomain: string;
  logoUrl?: string;
  primaryColor?: string;
  secondaryColor?: string;
  accentColor?: string;
  fontFamily?: string;
  isRtl?: boolean;
  branches?: any[];
  departments?: any[];
}

@Injectable()
export class TenantsService {
  constructor(private prisma: PrismaService) {}

  async createTenant(data: CreateTenantDto) {
    return this.prisma.tenant.create({
      data: {
        name: data.name,
        subdomain: data.subdomain.toLowerCase(),
        logoUrl: data.logoUrl,
        primaryColor: data.primaryColor || '#1A56DB',
        secondaryColor: data.secondaryColor || '#0E317A',
        accentColor: data.accentColor || '#F05252',
        fontFamily: data.fontFamily || 'IBM Plex Sans Arabic',
        isRtl: data.isRtl ?? true,
        branches: data.branches || [],
        departments: data.departments || [],
      },
    });
  }

  async getTenantBySubdomain(subdomain: string) {
    const tenant = await this.prisma.tenant.findUnique({
      where: { subdomain: subdomain.toLowerCase() },
    });
    if (!tenant) {
      throw new NotFoundException(`Enterprise Tenant with subdomain [${subdomain}] not registered.`);
    }
    return tenant;
  }

  async updateBranding(tenantId: string, brandingData: Partial<CreateTenantDto>) {
    return this.prisma.tenant.update({
      where: { id: tenantId },
      data: {
        ...brandingData,
        updatedAt: new Date(),
      },
    });
  }
}
