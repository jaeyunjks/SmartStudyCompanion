import { IsArray, IsIn, IsOptional, IsString, ValidateNested } from 'class-validator';
import { Type } from 'class-transformer';

export class WorkspaceChatHistoryMessageDto {
    @IsIn(['user', 'assistant'])
    role: 'user' | 'assistant';

    @IsString()
    content: string;
}

export class WorkspaceChatDto {
    @IsString()
    workspaceTitle: string;

    @IsString()
    prompt: string;

    @IsOptional()
    @IsString()
    workspaceContext?: string;

    @IsOptional()
    @IsArray()
    @ValidateNested({ each: true })
    @Type(() => WorkspaceChatHistoryMessageDto)
    conversationHistory?: WorkspaceChatHistoryMessageDto[];
}
