import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { FileRepository } from '../../modules/file/file.repository';

@Injectable()
export class PrismaFileRepository implements FileRepository {
    constructor(private prisma: PrismaService) {}

    async create(spaceId: string, name: string, mimeType: string, size: number, userId: string): Promise<any> {
        const studySpace = await this.prisma.studySpace.findUnique({
            where: {
                id: spaceId,
            },
        });

        if (!studySpace) {
            throw new InternalServerErrorException("space not found");
        }

        return this.prisma.file.create({
            data: {
                name,
                mimeType,
                size,
                userId,
                spaceId,
            },
        });
    }

    async updateById(id: string, userId: string, name?: string): Promise<any> {
        return this.prisma.file.update({
            where: {
                id,
                userId,
            },
            data: {
                name,
            },
        });        
    }

    async findById(id: string): Promise<any> {
        return this.prisma.file.findUnique({
            where: { 
                id, 
            },
        });
    }

    async findByStudySpaceId(spaceId: string): Promise<any> {
        return this.prisma.file.findMany({
            where: {
                spaceId,
            },
        });
    }

    async deleteById(id: string, userId: string): Promise<any> {
        return this.prisma.file.delete({
            where: { 
                id,
                userId,
            },
        });
    }

}