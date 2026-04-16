import { IsOptional, IsString } from "class-validator";

export class UpdateStudySpaceDto {
    @IsString()
    id!: string;

    @IsString()
    @IsOptional()
    title?: string;
}