import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { PasswordResetTokenRepository } from 'src/modules/password-reset-token/password-reset-token.repository';
import * as bcrypt from 'bcrypt';

@Injectable()
export class PrismaPasswordResetTokenRepository implements PasswordResetTokenRepository{
    constructor(private prisma: PrismaService) {}

    async create(userId: string, token: string, expiresAt: Date){
        const passwordResetToken = await this.prisma.passwordResetToken.create({
            data: { userId: userId, token: token, expiresAt: expiresAt}
        });
    }

    async getToken(rawToken: string){
        const tokens = await this.prisma.passwordResetToken.findMany({
            where: {
                used: false,
                expiresAt: {
                    gt: new Date()
                }
            }
        });

        for (const record of tokens) {
            const match = await bcrypt.compare(rawToken, record.token);

            if (match) {
                return record;
            }
        }

        return null;
    }

    async useToken(id: string) {
        const token = await this.prisma.passwordResetToken.update({
            where: { id },
            data: { used: true }
        })

        return token;
    }
}