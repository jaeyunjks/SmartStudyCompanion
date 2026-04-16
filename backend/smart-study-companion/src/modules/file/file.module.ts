import { Module, forwardRef } from '@nestjs/common';
import { FileService } from './file.service';
import { PrismaFileRepository } from 'src/database/prisma/prisma-file.repository';
import { FileController } from './file.controller';
import { StudySpaceModule } from '../study-space/study-space.module';
import { UserModule } from '../user/user.module';

@Module({
    imports: [
        forwardRef(() => StudySpaceModule),
        forwardRef(() => UserModule),
    ],
    providers: [
        FileService,
        {
            provide: 'FILE_REPOSITORY',
            useClass: PrismaFileRepository,
        }
    ],
    controllers: [
        FileController,
    ],
    exports: [
        FileService,
    ],
})
export class FileModule {}
