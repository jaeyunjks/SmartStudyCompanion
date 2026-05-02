import { IsHexColor, IsOptional, IsString } from "class-validator";

export class UpdateStudySpaceDto {
    @IsString()
    id!: string;

    @IsString()
    @IsOptional()
    title?: string;

    @IsHexColor()
    @IsOptional()
    color?: string;

    @IsString()
    @IsOptional()
    tag?: string;
}
