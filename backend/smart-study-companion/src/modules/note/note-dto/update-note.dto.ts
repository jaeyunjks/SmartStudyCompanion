import { IsObject, IsOptional, IsString } from "class-validator";

export class UpdateNoteDto {
    @IsString()
    id!: string;

    @IsString()
    @IsOptional()
    title?: string;

    @IsObject()
    @IsOptional()
    content?: Record<string, any>;
}