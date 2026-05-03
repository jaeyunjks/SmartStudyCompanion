import {
    Controller,
    Body,
    Get,
    Param,
    Post,
    Query,
    Request,
    NotFoundException,
    UseGuards,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt.guard';
import { AiService } from './ai.service';
import { ChatWithStudySpaceDto } from './ai-dto/chat-with-study-space.dto';
import { WorkspaceSummaryDto } from './ai-dto/workspace-summary.dto';
import { WorkspaceChatDto } from './ai-dto/workspace-chat.dto';

@Controller('api/ai')
export class AiController {
    constructor(
        private readonly aiService: AiService,
    ) {}

    @UseGuards(JwtAuthGuard)
    @Post('summary')
    async summarizeWorkspaceContent(
        @Body() summaryDto: WorkspaceSummaryDto,
        @Request() req: any,
    ) {
        const user = req.user;
        const userId = user?.userId;

        if (!userId) {
            throw new NotFoundException("User not found", "User not found");
        }

        return this.aiService.summarizeWorkspaceContent(
            summaryDto.workspaceTitle,
            summaryDto.workspaceContent,
        );
    }

    @UseGuards(JwtAuthGuard)
    @Post('workspace/chat')
    async chatWithWorkspaceContext(
        @Body() chatDto: WorkspaceChatDto,
        @Request() req: any,
    ) {
        const user = req.user;
        const userId = user?.userId;

        if (!userId) {
            throw new NotFoundException("User not found", "User not found");
        }

        return this.aiService.chatWithWorkspaceContext(
            chatDto.workspaceTitle,
            chatDto.prompt,
            chatDto.workspaceContext,
        );
    }

    @UseGuards(JwtAuthGuard)
    @Post('study-space/:id/summary')
    async summarizeStudySpace(
        @Param('id') id: string,
        @Request() req: any,
    ) {
        const user = req.user;
        const userId = user?.userId;

        if (!userId) {
            throw new NotFoundException("User not found", "User not found");
        }

        return this.aiService.summarizeStudySpace(id, userId);
    }

    @UseGuards(JwtAuthGuard)
    @Post('study-space/:id/chat')
    async chatWithStudySpace(
        @Param('id') id: string,
        @Body() chatDto: ChatWithStudySpaceDto,
        @Request() req: any,
    ) {
        const user = req.user;
        const userId = user?.userId;

        if (!userId) {
            throw new NotFoundException("User not found", "User not found");
        }

        return this.aiService.chatWithStudySpace(id, userId, chatDto.prompt, chatDto.chatHistoryId, chatDto.title);
    }

    @UseGuards(JwtAuthGuard)
    @Get('chat-history/:id')
    async getChatHistory(
        @Param('id') id: string,
        @Request() req: any,
    ) {
        const user = req.user;
        const userId = user?.userId;

        if (!userId) {
            throw new NotFoundException("User not found", "User not found");
        }

        return this.aiService.getChatHistory(id, userId);
    }

    @UseGuards(JwtAuthGuard)
    @Get('chat-history/:id/messages')
    async getChatHistoryMessages(
        @Param('id') id: string,
        @Query('limit') limit: string | undefined,
        @Query('beforeMessageId') beforeMessageId: string | undefined,
        @Request() req: any,
    ) {
        const user = req.user;
        const userId = user?.userId;

        if (!userId) {
            throw new NotFoundException("User not found", "User not found");
        }

        return this.aiService.getChatHistoryMessages(id, userId, limit, beforeMessageId);
    }
}
