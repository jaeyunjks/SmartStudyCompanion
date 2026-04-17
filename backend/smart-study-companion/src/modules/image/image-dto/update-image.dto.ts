import { IsOptional, IsString } from "class-validator";

export class UpdateImageDto {
    @IsString()
    id!: string;

    @IsString()
    @IsOptional()
    name?: string;
}