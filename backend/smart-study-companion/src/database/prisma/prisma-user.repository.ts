import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { UserRepository } from '../../modules/user/user.repository';

@Injectable()
export class PrismaUserRepository implements UserRepository {
    constructor(private prisma: PrismaService) {}

    async create(email: string, password: string, fullname: string, username: string) {
        return this.prisma.user.create({ 
            data: { 
                email, 
                password, 
                fullname,
                username,
            },
        });

    }

    async findAll() {
        return this.prisma.user.findMany();
    }

    async findByEmail(email: string) {
        return this.prisma.user.findUnique({
            where: { email },
        });
    }

    async findByUsername(username: string) {
        return this.prisma.user.findUnique({
            where: { username },
        });
    }

    async findById(id: string){
        return this.prisma.user.findUnique({
            where: { id }
        })
    }

    async updateById(id: string, fullname?: string): Promise<any> {
        return this.prisma.user.update({
            where: { id },
            data: {
                fullname,
            },
        });
    }

    async updateByUsername(username: string, fullname?: string, updatedUsername?: string): Promise<any> {
        return this.prisma.user.update({
            where: { username },
            data: {
                fullname,
                username: updatedUsername,
            },
        });
    }

    async updateSessionVersion(id: string) {
        return this.prisma.user.update({
            where: { id },
            data: { sessionVersion: { increment: 1 } },
        });
    }

    async validateSessionVersion(id: string, sessionVersion: number) {
        const user = await this.prisma.user.findUnique({
            where: { id: id },
            select: { sessionVersion: true },
        });

        return user?.sessionVersion === sessionVersion;
    }

    async resetPassword(id: string, password: string) {
        const user = await this.prisma.user.update({
            where: { id },
            data: { password }
        })

        return user;
    }
}