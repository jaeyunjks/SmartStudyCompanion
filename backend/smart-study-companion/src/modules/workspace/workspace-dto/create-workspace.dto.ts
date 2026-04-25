import { IsNumber, IsOptional, IsString, Max, Min } from 'class-validator';

export class CreateWorkspaceDto {
    @IsString()
    title: string;

    @IsOptional()
    @IsString()
    description?: string;

    @IsString()
    iconName: string;

    @IsString()
    category: string;

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
