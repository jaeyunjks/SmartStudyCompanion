import { IsOptional, IsString } from 'class-validator';

export class ChatWithStudySpaceDto {
    @IsString()
    prompt: string;

    @IsOptional()
    @IsString()
    chatHistoryId?: string;

    @IsOptional()
    @IsString()
    title?: string;
}
