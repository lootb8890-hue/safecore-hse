import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';

export interface CreateTaskDto {
  title: string;
  description?: string;
  assignedToId: string;
  priority?: 'LOW' | 'NORMAL' | 'HIGH' | 'URGENT';
  dueDate: string;
}

export interface UpdateTaskDto {
  status?: 'PENDING' | 'IN_PROGRESS' | 'COMPLETED' | 'OVERDUE';
  progressPercentage?: number;
}

@Injectable()
export class TasksService {
  constructor(private prisma: PrismaService) {}

  async createTask(tenantId: string, createdById: string, data: CreateTaskDto) {
    const task = await this.prisma.taskItem.create({
      data: {
        tenantId,
        title: data.title,
        description: data.description,
        assignedToId: data.assignedToId,
        createdById,
        priority: (data.priority as any) || 'NORMAL',
        status: 'PENDING',
        progressPercentage: 0,
        dueDate: new Date(data.dueDate),
      },
    });

    await this.prisma.auditLog.create({
      data: {
        tenantId,
        actorId: createdById,
        actionType: 'TASK_CREATED_AND_ASSIGNED',
        targetEntity: 'TASK_ITEM',
        targetId: task.id,
        newValues: { title: task.title, assignedTo: task.assignedToId, due: task.dueDate },
      },
    });

    return task;
  }

  async getTodaysTasks(tenantId: string, userId: string) {
    const now = new Date();
    const startOfDay = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const endOfDay = new Date(startOfDay);
    endOfDay.setDate(endOfDay.getDate() + 1);

    // 1. Fetch direct assigned tasks
    const tasks = await this.prisma.taskItem.findMany({
      where: {
        tenantId,
        assignedToId: userId,
        status: { in: ['PENDING', 'IN_PROGRESS', 'OVERDUE'] },
      },
      orderBy: { dueDate: 'asc' },
    });

    // 2. Fetch required asset inspections due today or overdue
    const pendingInspections = await this.prisma.safetyAsset.findMany({
      where: {
        tenantId,
        nextInspection: { lte: endOfDay },
      },
      select: { id: true, assetNumber: true, name: true, layerType: true, nextInspection: true },
      take: 10,
    });

    // 3. Fetch active open incident remediation tickets
    const openIncidents = await this.prisma.incident.findMany({
      where: { tenantId, status: { in: ['ACTIVE_ALARM', 'UNDER_INVESTIGATION'] } },
      select: { id: true, emergencyType: true, locationText: true, reportedAt: true },
      take: 5,
    });

    return {
      summary: {
        openTasksCount: tasks.length,
        dueInspectionsCount: pendingInspections.length,
        urgentRemediationsCount: openIncidents.length,
      },
      assignedTasks: tasks,
      requiredInspections: pendingInspections,
      urgentRemediations: openIncidents,
      generatedAt: new Date().toISOString(),
    };
  }

  async getComprehensiveCalendar(tenantId: string, month?: number, year?: number) {
    // Return combined schedule of inspections, training tasks, and maintenance
    const tasks = await this.prisma.taskItem.findMany({
      where: { tenantId },
      include: { assignedTo: { select: { fullName: true } } },
    });

    const assetsWithUpcomingInspections = await this.prisma.safetyAsset.findMany({
      where: { tenantId, nextInspection: { not: null } },
      select: { id: true, assetNumber: true, name: true, nextInspection: true },
    });

    const calendarEvents: any[] = [];

    tasks.forEach((t) => {
      calendarEvents.push({
        id: t.id,
        eventType: 'TASK_ASSIGNMENT',
        title: t.title,
        date: t.dueDate,
        status: t.status,
        assignee: (t as any).assignedTo?.fullName,
      });
    });

    assetsWithUpcomingInspections.forEach((a) => {
      calendarEvents.push({
        id: a.id,
        eventType: 'SCHEDULED_INSPECTION',
        title: `Inspection Due: ${a.name} (${a.assetNumber})`,
        date: a.nextInspection,
        status: 'PENDING_CHECKUP',
      });
    });

    return {
      calendarEvents: calendarEvents.sort((a, b) => new Date(a.date).getTime() - new Date(b.date).getTime()),
      totalEvents: calendarEvents.length,
    };
  }

  async updateTaskProgress(tenantId: string, actorId: string, taskId: string, data: UpdateTaskDto) {
    const task = await this.prisma.taskItem.findFirst({ where: { tenantId, id: taskId } });
    if (!task) {
      throw new NotFoundException(`Task [${taskId}] not found.`);
    }

    const updated = await this.prisma.taskItem.update({
      where: { id: taskId },
      data: {
        status: data.status as any,
        progressPercentage: data.progressPercentage !== undefined ? data.progressPercentage : task.progressPercentage,
      },
    });

    return updated;
  }
}
