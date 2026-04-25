import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from 'src/prisma/prisma.service';
import { CreateWorkspaceDto } from './workspace-dto/create-workspace.dto';
import { UpdateWorkspaceDto } from './workspace-dto/update-workspace.dto';

@Injectable()
export class WorkspaceService {
    constructor(private readonly prisma: PrismaService) {}

    private get workspaceModel() {
        return (this.prisma as any).studyWorkspace;
    }

    async listForUser(userId: string) {
        const workspaces = await this.workspaceModel.findMany({
            where: { userId },
            orderBy: { updatedAt: 'desc' },
        });
        return workspaces.map((workspace) => this.serializeWorkspace(workspace));
    }

    async createForUser(userId: string, dto: CreateWorkspaceDto) {
        const created = await this.workspaceModel.create({
            data: {
                userId,
                title: dto.title?.trim() || 'Untitled Workspace',
                description: dto.description?.trim() || 'No description yet.',
                iconName: dto.iconName || 'folder',
                category: dto.category || 'General',
                status: dto.status || 'Active',
                workspaceColorHex: dto.workspaceColorHex || '#388767',
                documentCount: dto.documentCount ?? 0,
                noteCount: dto.noteCount ?? 0,
                aiOutputCount: dto.aiOutputCount ?? 0,
                progress: dto.progress ?? 0,
            },
        });
        return this.serializeWorkspace(created);
    }

    async updateForUser(userId: string, workspaceId: string, dto: UpdateWorkspaceDto) {
        const existing = await this.workspaceModel.findFirst({
            where: { id: workspaceId, userId },
        });

        if (!existing) {
            throw new NotFoundException('Workspace not found');
        }

        const updated = await this.workspaceModel.update({
            where: { id: workspaceId },
            data: {
                title: dto.title,
                description: dto.description,
                iconName: dto.iconName,
                category: dto.category,
                status: dto.status,
                workspaceColorHex: dto.workspaceColorHex,
                documentCount: dto.documentCount,
                noteCount: dto.noteCount,
                aiOutputCount: dto.aiOutputCount,
                progress: dto.progress,
            },
        });

        return this.serializeWorkspace(updated);
    }

    async deleteForUser(userId: string, workspaceId: string) {
        const existing = await this.workspaceModel.findFirst({
            where: { id: workspaceId, userId },
        });

        if (!existing) {
            throw new NotFoundException('Workspace not found');
        }

        await this.workspaceModel.delete({ where: { id: workspaceId } });
        return { success: true };
    }

    private serializeWorkspace(workspace: any) {
        return {
            id: workspace.id,
            userId: workspace.userId,
            title: workspace.title,
            description: workspace.description,
            iconName: workspace.iconName,
            category: workspace.category,
            status: workspace.status,
            workspaceColorHex: workspace.workspaceColorHex,
            documentCount: workspace.documentCount,
            noteCount: workspace.noteCount,
            aiOutputCount: workspace.aiOutputCount,
            progress: workspace.progress,
            createdAt: workspace.createdAt,
            updatedAt: workspace.updatedAt,
        };
    }
}
