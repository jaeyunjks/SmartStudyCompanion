import { ArrayNotEmpty, IsArray, IsOptional, IsString } from 'class-validator';

export class SummarizeStudySpaceDto {
    @IsArray()
    @ArrayNotEmpty()
    @IsString({ each: true })
    fileIds: string[];

    @IsOptional()
    @IsString()
    title?: string;
}
