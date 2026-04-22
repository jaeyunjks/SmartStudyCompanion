import { Test, TestingModule } from '@nestjs/testing';
import { StudySpaceController } from './study-space.controller';

describe('StudySpaceController', () => {
  let controller: StudySpaceController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [StudySpaceController],
    }).compile();

    controller = module.get<StudySpaceController>(StudySpaceController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
