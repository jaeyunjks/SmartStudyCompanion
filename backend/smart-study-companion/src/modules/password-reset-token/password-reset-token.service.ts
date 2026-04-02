import { Injectable, Inject, UnauthorizedException } from '@nestjs/common';
import { PasswordResetTokenRepository } from './password-reset-token.repository';

@Injectable()
export class PasswordResetTokenService {
    constructor(
        @Inject('PASSWORD_RESET_TOKEN_REPOSITORY')
        private readonly passwordResetTokenRepo: PasswordResetTokenRepository,
    ) {}

    async createPasswordResetToken(userId: string, token: string) {
        const expiresAt = new Date(Date.now() + Number(process.env.RESET_LINK_DURATION));

        return this.passwordResetTokenRepo.create(userId, token, expiresAt);
    }

    async getPasswordResetToken(rawToken: string) {
        return this.passwordResetTokenRepo.getToken(rawToken);
    }
    
    async usePasswordResetToken(tokenId: string){
        return this.passwordResetTokenRepo.useToken(tokenId);
    }
}