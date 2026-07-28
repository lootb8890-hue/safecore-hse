import { Controller, Post, Get, Body, Param, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { AiService } from './ai.service';
import { RbacGuard } from '../../common/guards/rbac.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';

@ApiTags('Artificial Intelligence Safety & Analytics')
@ApiBearerAuth()
@UseGuards(RbacGuard)
@Controller('ai')
export class AiController {
  constructor(private readonly aiService: AiService) {}

  @Post('analyze-photo')
  @Roles('ADMIN', 'MEMBER')
  @ApiOperation({
    summary: 'AI Vision: Analyze workplace photograph for PPE breaches, blocked emergency exits & safety hazards',
  })
  @ApiResponse({ status: 200, description: 'Detected violations with OSHA/ISO references & suggested corrective actions.' })
  async analyzePhoto(
    @CurrentUser('tenantId') tenantId: string,
    @CurrentUser('id') actorId: string,
    @Body() body: { imageUrl: string; notes?: string },
  ) {
    return this.aiService.analyzeHazardPhoto(tenantId, actorId, body.imageUrl, body.notes);
  }

  @Get('summarize-incident/:id')
  @Roles('ADMIN', 'MEMBER')
  @ApiOperation({ summary: 'AI Executive Summarizer: Synthesize emergency incident reports & propose Risk Assessments' })
  async summarizeIncident(@CurrentUser('tenantId') tenantId: string, @Param('id') id: string) {
    return this.aiService.summarizeIncident(tenantId, id);
  }

  @Get('smart-search')
  @Roles('ADMIN', 'MEMBER')
  @ApiOperation({ summary: 'AI Semantic Search: Cross-reference documents, safety assets & incident archives instantly' })
  @ApiQuery({ name: 'q', required: true, description: 'Search keywords (e.g. extinguisher inspection zone A)' })
  async search(@CurrentUser('tenantId') tenantId: string, @Query('q') query: string) {
    return this.aiService.smartSearch(tenantId, query);
  }
}
