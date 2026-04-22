import { forwardRef, Module } from '@nestjs/common';
import { ImageService } from './image.service';
import { ImageController } from './image.controller';
import { PrismaImageRepository } from 'src/database/prisma/prisma-image.repository';
import { StudySpaceModule } from '../study-space/study-space.module';
import { UserModule } from '../user/user.module';

@Module({
    imports: [
        forwardRef(() => StudySpaceModule),
        forwardRef(() => UserModule),
    ],
    providers: [
        ImageService,
        {
            provide: 'IMAGE_REPOSITORY',
            useClass: PrismaImageRepository,
        }
    ],
    controllers: [
        ImageController,
    ],
    exports: [
        ImageService,
    ],
})
export class ImageModule {}
