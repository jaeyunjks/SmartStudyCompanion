import { IsArray, IsOptional, IsString } from 'class-validator';

export class SummarizeStudySpaceDto {
    @IsOptional()
    @IsArray()
    @IsString({ each: true })
    fileIds?: string[];

    @IsOptional()
    @IsString()
    title?: string;

    @IsOptional()
    @IsString()
    sourceContent?: string;
}
