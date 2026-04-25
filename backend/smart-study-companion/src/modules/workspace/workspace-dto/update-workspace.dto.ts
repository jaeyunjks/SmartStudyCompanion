import { IsNumber, IsOptional, IsString, Max, Min } from 'class-validator';

export class UpdateWorkspaceDto {
    @IsOptional()
    @IsString()
    title?: string;

    @IsOptional()
    @IsString()
    description?: string;

    @IsOptional()
    @IsString()
    iconName?: string;

    @IsOptional()
    @IsString()
    category?: string;

    @IsOptional()
    @IsString()
    status?: string;

    @IsOptional()
    @IsString()
    workspaceColorHex?: string;

    @IsOptional()
    @IsNumber()
    documentCount?: number;

    @IsOptional()
    @IsNumber()
    noteCount?: number;

    @IsOptional()
    @IsNumber()
    aiOutputCount?: number;

    @IsOptional()
    @IsNumber()
    @Min(0)
    @Max(1)
    progress?: number;
}
