import { NotFoundException } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { StudySpaceController } from './study-space.controller';
import { StudySpaceService } from './study-space.service';

describe('StudySpaceController Layer1', () => {
  let controller: StudySpaceController;
  let studySpaceService: jest.Mocked<StudySpaceService>;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [StudySpaceController],
      providers: [
        {
          provide: StudySpaceService,
          useValue: {
            getStudySpaceById: jest.fn(),
            getStudySpacesByUserId: jest.fn(),
            createStudySpace: jest.fn(),
            updateStudySpaceById: jest.fn(),
            deleteStudySpaceById: jest.fn(),
          },
        },
      ],
    }).compile();

    controller = module.get(StudySpaceController);
    studySpaceService = module.get(StudySpaceService);
  });

  it('getStudySpace returns study space and ownership flag', async () => {
    studySpaceService.getStudySpaceById.mockResolvedValue({ id: 'space-1', userId: 'user-1', title: 'Algorithms' } as any);

    await expect(controller.getStudySpace('space-1', { user: { userId: 'user-1' } })).resolves.toEqual({
      isOwner: true,
      studySpace: { id: 'space-1', userId: 'user-1', title: 'Algorithms' },
    });
  });

  it('getStudySpaces returns list with ownership flag', async () => {
    studySpaceService.getStudySpacesByUserId.mockResolvedValue([{ id: 'space-1', userId: 'user-1', title: 'Algorithms' }] as any);

    const result = await controller.getStudySpaces('user-1', { user: { userId: 'user-1' } });
    expect(result.isOwner).toBe(true);
    expect(result.studySpaces).toHaveLength(1);
  });

  it('addStudySpace forwards title and authenticated userId', async () => {
    studySpaceService.createStudySpace.mockResolvedValue({ id: 'space-1', userId: 'user-1', title: 'Algorithms' } as any);

    await expect(controller.addStudySpace({ title: 'Algorithms' }, { user: { userId: 'user-1' } })).resolves.toEqual({
      id: 'space-1', userId: 'user-1', title: 'Algorithms',
    });
  });

  it('throws NotFoundException when request has no authenticated user', async () => {
    await expect(controller.getStudySpace('space-1', { user: undefined })).rejects.toBeInstanceOf(NotFoundException);
  });
});
