import { Controller, Post, Get, Put, Body, Param, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { TenantsService, CreateTenantDto } from './tenants.service';
import { Roles } from '../../common/decorators/roles.decorator';
import { RbacGuard } from '../../common/guards/rbac.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';

@ApiTags('Tenant & White-Label Customization')
@Controller('tenants')
export class TenantsController {
  constructor(private readonly tenantsService: TenantsService) {}

  @Post('register')
  @ApiOperation({ summary: 'Register a new Enterprise Tenant workspace with customized branding' })
  @ApiResponse({ status: 201, description: 'Tenant enterprise successfully created.' })
  async register(@Body() body: CreateTenantDto) {
    return this.tenantsService.createTenant(body);
  }

  @Get('subdomain/:subdomain')
  @ApiOperation({ summary: 'Retrieve full White-Label theme, color hexes, and logo for a tenant subdomain' })
  async getBySubdomain(@Param('subdomain') subdomain: string) {
    return this.tenantsService.getTenantBySubdomain(subdomain);
  }

  @Put('branding/update')
  @ApiBearerAuth()
  @UseGuards(RbacGuard)
  @Roles('ADMIN')
  @ApiOperation({ summary: '(Admin Only) Update corporate logos, font families, colors, and branches' })
  async updateBranding(@CurrentUser('tenantId') tenantId: string, @Body() body: Partial<CreateTenantDto>) {
    return this.tenantsService.updateBranding(tenantId, body);
  }
}
