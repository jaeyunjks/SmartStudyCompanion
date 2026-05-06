import { Injectable, InternalServerErrorException } from "@nestjs/common";
import { PrismaService } from "src/prisma/prisma.service";
import { StudySpaceRepository } from "src/modules/study-space/study-space.repository";

@Injectable()
export class PrismaStudySpaceRepository implements StudySpaceRepository {
    constructor(private readonly prisma: PrismaService){}

    async create(title: string, userId: string, color?: string, tag?: string): Promise<any> {
        return this.prisma.studySpace.create({
            data: {
                title,
                userId,
                color,
                tag,
            },
        });
    }

    async updateById(id: string, userId: string, title?: string, color?: string, tag?: string): Promise<any> {
        return this.prisma.studySpace.update({
            where: {
                id,
                userId,
            },
            data: {
                title,
                color,
                tag,
            },
        });
    }

    async updateSummaryById(id: string, userId: string, summary: any): Promise<any> {
        return this.prisma.studySpace.update({
            where: {
                id,
                userId,
            },
            data: {
                summary,
            },
        });
    }

    async delete(id: string, userId: string): Promise<any> {
        return this.prisma.studySpace.delete({
            where: {
                id,
                userId,
            },
        });
    }

    async getById(id: string): Promise<any> {
        return this.prisma.studySpace.findUnique({
            where: {
                id,
            },
        });
    }

    async getByUserId(userId: string): Promise<any> {
        return this.prisma.studySpace.findMany({
            where: {
                userId,
            },
        });
    }
}
