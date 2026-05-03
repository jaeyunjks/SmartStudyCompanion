import { IsOptional, IsString } from 'class-validator';

export class WorkspaceChatDto {
    @IsString()
    workspaceTitle: string;

    @IsString()
    prompt: string;

    @IsOptional()
    @IsString()
    workspaceContext?: string;
}
