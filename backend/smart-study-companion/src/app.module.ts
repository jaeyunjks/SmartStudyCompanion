import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { MailerModule } from '@nestjs-modules/mailer';
import { UserModule } from './modules/user/user.module';
import { AuthModule } from './modules/auth/auth.module';
import { PasswordResetTokenModule } from './modules/password-reset-token/password-reset-token.module';
import { StudySpaceModule } from './modules/study-space/study-space.module';
import { NoteModule } from './modules/note/note.module';
import { ImageModule } from './modules/image/image.module';
import { FileModule } from './modules/file/file.module';

@Module({
    imports: [
        ConfigModule.forRoot({
            isGlobal: true,
        }),
        MailerModule.forRootAsync({
            inject: [ConfigService],
            useFactory: (config: ConfigService) => ({
                transport: {
                    host: 'smtp.gmail.com',
                    port: 587,
                    secure: false,
                    auth: {
                        user: config.get<string>('MAIL_USER'),
                        pass: config.get<string>('MAIL_PASSWORD'),
                    },
                },
            }),
        }),
        UserModule,
        AuthModule,
        PasswordResetTokenModule,
        StudySpaceModule,
        NoteModule,
        ImageModule,
        FileModule,
    ],
    controllers: [
        AppController
    ],
    providers: [
        AppService
    ],
})
export class AppModule {}