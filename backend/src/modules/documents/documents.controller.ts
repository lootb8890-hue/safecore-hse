import { Controller, Post, Get, Delete, Body, Param, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { DocumentsService, UploadDocumentDto } from './documents.service';
import { RbacGuard } from '../../common/guards/rbac.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';

@ApiTags('Document & SOP Center')
@ApiBearerAuth()
@UseGuards(RbacGuard)
@Controller('documents')
export class DocumentsController {
  constructor(private readonly documentsService: DocumentsService) {}

  @Post()
  @Roles('ADMIN', 'MEMBER')
  @ApiOperation({ summary: 'Upload corporate safety policy, SOP manual, MSDS sheet, or investigation video' })
  async upload(
    @CurrentUser('tenantId') tenantId: string,
    @CurrentUser('id') uploaderId: string,
    @Body() body: UploadDocumentDto,
  ) {
    return this.documentsService.uploadDocument(tenantId, uploaderId, body);
  }

  @Get()
  @Roles('ADMIN', 'MEMBER')
  @ApiOperation({ summary: 'Search safety repository by category or title keywords' })
  @ApiQuery({ name: 'category', required: false })
  @ApiQuery({ name: 'query', required: false })
  async list(
    @CurrentUser('tenantId') tenantId: string,
    @Query('category') category?: string,
    @Query('query') query?: string,
  ) {
    return this.documentsService.listDocuments(tenantId, category, query);
  }

  @Delete(':id')
  @Roles('ADMIN')
  @ApiOperation({ summary: '(Admin Only) Delete an obsolete safety governance document or MSDS sheet' })
  async remove(@CurrentUser('tenantId') tenantId: string, @CurrentUser('id') actorId: string, @Param('id') id: string) {
    return this.documentsService.deleteDocument(tenantId, actorId, id);
  }
}
