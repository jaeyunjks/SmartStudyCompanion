import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { ImageRepository } from '../../modules/image/image.repository';

@Injectable()
export class PrismaImageRepository implements ImageRepository {
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

        return this.prisma.image.create({
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
        return this.prisma.image.update({
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
        return this.prisma.image.findUnique({
            where: { 
                id, 
            },
        });
    }

    async findByStudySpaceId(spaceId: string): Promise<any> {
        return this.prisma.image.findMany({
            where: {
                spaceId,
            },
        });
    }

    async deleteById(id: string, userId: string): Promise<any> {
        return this.prisma.image.delete({
            where: { 
                id,
                userId,
            },
        });
    }

}