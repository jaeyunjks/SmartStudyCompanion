import { Module } from '@nestjs/common';
import { UserController } from './user.controller';
import { UserService } from './user.service';
import { PrismaUserRepository } from 'src/database/prisma/prisma-user.repository';
import { PrismaModule } from 'src/prisma/prisma.module';

@Module({
    imports: [
        PrismaModule,
    ],
    controllers: [
        UserController
    ],
    providers: [
        UserService,
        {
            provide: 'USER_REPOSITORY',
            useClass: PrismaUserRepository,
        }
    ],
    exports: [
        UserService,
    ],
})
export class UserModule {}
