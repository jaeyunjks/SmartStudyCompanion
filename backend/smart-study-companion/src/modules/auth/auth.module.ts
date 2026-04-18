import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { AuthService } from './auth.service';
import { AuthController } from './auth.controller';
import { JwtStrategy } from './jwt.strategy';
import { UserModule } from '../user/user.module';
import { PasswordResetTokenModule } from '../password-reset-token/password-reset-token.module';
import { ConfigService } from '@nestjs/config';
import { MailService } from '../mail/mail.service';

@Module({
    imports: [
        UserModule,
        PassportModule,
        JwtModule.registerAsync({
            inject: [ConfigService],
            useFactory: (configService: ConfigService) => {
                const secret = configService.get<string>('JWT_SECRET_KEY');
                if (!secret) {
                throw new Error('JWT_SECRET_KEY is not defined');
                }

                const expiresInRaw = configService.get<string>('JWT_EXPIRES_IN');
                const expiresIn = expiresInRaw ? Number(expiresInRaw) : 86400;

                return {
                    secret,
                    signOptions: { expiresIn },
                };
            },
        }),
        PasswordResetTokenModule,
    ],
    providers: [
        AuthService, 
        JwtStrategy, 
        MailService,
    ],
    controllers: [
        AuthController,
    ],
})
export class AuthModule {}
