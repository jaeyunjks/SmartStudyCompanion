import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { NoteRepository } from 'src/modules/note/note.repository';

@Injectable()
export class PrismaNoteRepository implements NoteRepository {
    constructor (
        private prisma: PrismaService,
    ) {}

    async create(title: string, spaceId: string, userId: string, content?: any): Promise<any> {
        return this.prisma.note.create({
            data: {
                title,
                spaceId,
                userId,
                content,
            },
        });
    }

    async update(id: string, userId: string, title?: string, content?: any): Promise<any> {
        return this.prisma.note.update({
            where: {
                id,
                userId,
            },
            data: {
                title,
                content,
            },
        });
    }

    async delete(id: string, userId: string): Promise<any> {
        return this.prisma.note.delete({
            where: {
                id,
                userId,
            },
        });
    }

    async getById(id: string): Promise<any> {
        return this.prisma.note.findUnique({
            where: {
                id,
            },
        });
    }

    async getBySpaceId(spaceId: string): Promise<any> {
        return this.prisma.note.findMany({
            where: {
                spaceId,
            },
        });
    }
}