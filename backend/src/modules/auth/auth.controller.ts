import { Controller, Post, Body, Get, UseGuards, Req } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { AuthService, RegisterUserDto, EnterpriseSetupDto, LoginDto } from './auth.service';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { RbacGuard } from '../../common/guards/rbac.guard';

@ApiTags('Authentication & Identity')
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('setup-enterprise')
  @ApiOperation({ summary: 'Atomically provision a new Enterprise Workspace and its sovereign Admin account' })
  @ApiResponse({ status: 201, description: 'Enterprise workspace and Admin user successfully onboarded.' })
  async setupEnterprise(@Body() body: EnterpriseSetupDto) {
    return this.authService.setupEnterprise(body);
  }

  @Post('register')
  @ApiOperation({ summary: 'Register a new Safety Member account inside a Tenant workspace (Member Role Only)' })
  @ApiResponse({ status: 201, description: 'User account created with MEMBER role.' })
  async register(@Body() body: RegisterUserDto) {
    return this.authService.register(body);
  }

  @Post('login')
  @ApiOperation({ summary: 'Authenticate user credentials & retrieve full Tenant White-Label UI parameters' })
  @ApiResponse({ status: 200, description: 'Authentication verification success.' })
  async login(@Body() body: LoginDto) {
    return this.authService.login(body);
  }

  @Get('me')
  @ApiBearerAuth()
  @UseGuards(RbacGuard)
  @ApiOperation({ summary: 'Retrieve authenticated user profile and active security permissions' })
  async getProfile(@CurrentUser() user: any) {
    return { success: true, profile: user };
  }
}
