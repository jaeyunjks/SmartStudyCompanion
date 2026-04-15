import { Module } from '@nestjs/common';
import { StudySpaceService } from './study-space.service';
import { StudySpaceController } from './study-space.controller';

@Module({
  providers: [StudySpaceService],
  controllers: [StudySpaceController]
})
export class StudySpaceModule {}
