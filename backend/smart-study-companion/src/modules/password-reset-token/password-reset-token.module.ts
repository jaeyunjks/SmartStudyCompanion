import { Module } from '@nestjs/common';
import { PrismaModule } from '../../prisma/prisma.module';
import { UserModule } from '../user/user.module';
import { PasswordResetTokenService } from './password-reset-token.service';
import { PrismaPasswordResetTokenRepository } from 'src/database/prisma/prisma-password-reset-token.repository';

@Module({
    imports: [
        PrismaModule,
        UserModule,
    ],
    providers: [
        PasswordResetTokenService,
        {
            provide: 'PASSWORD_RESET_TOKEN_REPOSITORY',
            useClass: PrismaPasswordResetTokenRepository,
        }
    ],
    exports: [PasswordResetTokenService],
})
export class PasswordResetTokenModule {}
