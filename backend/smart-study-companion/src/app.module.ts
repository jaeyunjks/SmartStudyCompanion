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
import { DocumentController } from './modules/document/document.controller';
import { DocumentService } from './modules/document/document.service';
import { DocumentModule } from './modules/document/document.module';
import { ImageModule } from './modules/image/image.module';
import { FileController } from './modules/file/file.controller';
import { FileService } from './modules/file/file.service';
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
        DocumentModule,
        ImageModule,
        FileModule,
    ],
    controllers: [AppController, DocumentController, FileController],
    providers: [AppService, DocumentService, FileService],
})
export class AppModule {}