import { Body, Controller, Delete, Get, Param, Post, Put, Request, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt.guard';
import { WorkspaceService } from './workspace.service';
import { CreateWorkspaceDto } from './workspace-dto/create-workspace.dto';
import { UpdateWorkspaceDto } from './workspace-dto/update-workspace.dto';

@Controller('api/workspaces')
@UseGuards(JwtAuthGuard)
export class WorkspaceController {
    constructor(private readonly workspaceService: WorkspaceService) {}

    @Get()
    async listMine(@Request() req: any) {
        return this.workspaceService.listForUser(req.user.userId);
    }

    @Post()
    async create(
        @Request() req: any,
        @Body() createWorkspaceDto: CreateWorkspaceDto,
    ) {
        return this.workspaceService.createForUser(req.user.userId, createWorkspaceDto);
    }

    @Put(':id')
    async update(
        @Request() req: any,
        @Param('id') id: string,
        @Body() updateWorkspaceDto: UpdateWorkspaceDto,
    ) {
        return this.workspaceService.updateForUser(req.user.userId, id, updateWorkspaceDto);
    }

    @Delete(':id')
    async delete(
        @Request() req: any,
        @Param('id') id: string,
    ) {
        return this.workspaceService.deleteForUser(req.user.userId, id);
    }
}
