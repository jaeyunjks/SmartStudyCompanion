import { IsHexColor, IsOptional, IsString } from "class-validator";


export class AddStudySpaceDto {
    @IsString()
    title!: string;

    @IsHexColor()
    @IsOptional()
    color?: string;

    @IsString()
    @IsOptional()
    tag?: string;
}
