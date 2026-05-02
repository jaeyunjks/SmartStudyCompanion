import { IsString } from 'class-validator';

export class WorkspaceSummaryDto {
    @IsString()
    workspaceId: string;

    @IsString()
    workspaceTitle: string;

    @IsString()
    workspaceContent: string;
}
