import { Test, TestingModule } from '@nestjs/testing';
import { StudySpaceService } from './study-space.service';

describe('StudySpaceService', () => {
  let service: StudySpaceService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [StudySpaceService],
    }).compile();

    service = module.get<StudySpaceService>(StudySpaceService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
