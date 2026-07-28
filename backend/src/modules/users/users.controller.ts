import { Controller, Get, Post, Patch, Delete, Body, Param, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { UsersService, CreateMemberDto, UpdateMemberDto } from './users.service';
import { Roles } from '../../common/decorators/roles.decorator';
import { RbacGuard } from '../../common/guards/rbac.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';

@ApiTags('Enterprise Team & Member Governance')
@ApiBearerAuth()
@UseGuards(RbacGuard)
@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Post('members')
  @Roles('ADMIN')
  @ApiOperation({ summary: '(Admin Only) Provision a new Safety Member or Inspector into the organization' })
  @ApiResponse({ status: 201, description: 'Member profile created under Admin supervision.' })
  async createMember(
    @CurrentUser('tenantId') tenantId: string,
    @CurrentUser('id') adminId: string,
    @Body() body: CreateMemberDto,
  ) {
    return this.usersService.createMember(tenantId, adminId || 'admin_gov', body);
  }

  @Get('members')
  @Roles('ADMIN', 'MEMBER')
  @ApiOperation({ summary: 'Retrieve active directory of safety engineers & facility staff' })
  async getMembers(@CurrentUser('tenantId') tenantId: string) {
    return this.usersService.getMembers(tenantId);
  }

  @Patch('members/:id')
  @Roles('ADMIN')
  @ApiOperation({ summary: '(Admin Only) Modify member operational role, branch, or activity status' })
  async updateMember(
    @CurrentUser('tenantId') tenantId: string,
    @CurrentUser('id') adminId: string,
    @Param('id') memberId: string,
    @Body() body: UpdateMemberDto,
  ) {
    return this.usersService.updateMember(tenantId, memberId, adminId || 'admin_gov', body);
  }

  @Delete('members/:id')
  @Roles('ADMIN')
  @ApiOperation({ summary: '(Admin Only) Revoke access and deactivate facility member profile' })
  async removeMember(
    @CurrentUser('tenantId') tenantId: string,
    @CurrentUser('id') adminId: string,
    @Param('id') memberId: string,
  ) {
    return this.usersService.removeMember(tenantId, memberId, adminId || 'admin_gov');
  }
}
