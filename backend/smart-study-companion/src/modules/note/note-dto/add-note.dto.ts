import { IsObject, IsOptional, IsString } from "class-validator";

export class AddNoteDto {
    @IsString()
    title!: string;

    @IsString()
    spaceId!: string;

    @IsObject()
    @IsOptional()
    content?: Record<string, any>;
}