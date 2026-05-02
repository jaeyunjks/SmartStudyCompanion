import { Module } from '@nestjs/common';
import { StudySpaceService } from './study-space.service';
import { StudySpaceController } from './study-space.controller';
import { PrismaStudySpaceRepository } from 'src/database/prisma/prisma-study-space.repository';

@Module({
    imports: [

    ],
    providers: [
        StudySpaceService,
        {
            provide: 'STUDY_SPACE_REPOSITORY',
            useClass: PrismaStudySpaceRepository,
        }
    ],
    controllers: [
        StudySpaceController,
    ],
    exports: [
        StudySpaceService,
    ]
})
export class StudySpaceModule {}
