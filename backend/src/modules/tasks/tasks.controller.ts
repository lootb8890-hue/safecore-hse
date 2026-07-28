import { Controller, Post, Get, Put, Body, Param, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { TasksService, CreateTaskDto, UpdateTaskDto } from './tasks.service';
import { RbacGuard } from '../../common/guards/rbac.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';

@ApiTags('Tasks, Daily Work & Comprehensive Calendar')
@ApiBearerAuth()
@UseGuards(RbacGuard)
@Controller('tasks')
export class TasksController {
  constructor(private readonly tasksService: TasksService) {}

  @Post()
  @Roles('ADMIN', 'MEMBER')
  @ApiOperation({ summary: 'Create and assign a safety inspection or remediation work task with priority & deadline' })
  async create(
    @CurrentUser('tenantId') tenantId: string,
    @CurrentUser('id') creatorId: string,
    @Body() body: CreateTaskDto,
  ) {
    return this.tasksService.createTask(tenantId, creatorId, body);
  }

  @Get('today')
  @Roles('ADMIN', 'MEMBER')
  @ApiOperation({ summary: "TODAY'S TASKS: Consolidated feed of user tasks, required inspections & permits due today" })
  async getToday(@CurrentUser('tenantId') tenantId: string, @CurrentUser('id') userId: string) {
    return this.tasksService.getTodaysTasks(tenantId, userId);
  }

  @Get('calendar')
  @Roles('ADMIN', 'MEMBER')
  @ApiOperation({ summary: 'COMPREHENSIVE CALENDAR: Aggregate view of scheduled inspections, training, maintenance & leave' })
  @ApiQuery({ name: 'month', required: false })
  @ApiQuery({ name: 'year', required: false })
  async getCalendar(
    @CurrentUser('tenantId') tenantId: string,
    @Query('month') month?: number,
    @Query('year') year?: number,
  ) {
    return this.tasksService.getComprehensiveCalendar(tenantId, month, year);
  }

  @Put(':id/progress')
  @Roles('ADMIN', 'MEMBER')
  @ApiOperation({ summary: 'Update completion status or percentage progress of a task' })
  async updateProgress(
    @CurrentUser('tenantId') tenantId: string,
    @CurrentUser('id') actorId: string,
    @Param('id') id: string,
    @Body() body: UpdateTaskDto,
  ) {
    return this.tasksService.updateTaskProgress(tenantId, actorId, id, body);
  }
}
