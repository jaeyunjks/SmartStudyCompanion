import { NotFoundException } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { FileController } from '../src/modules/file/file.controller';
import { FileService } from '../src/modules/file/file.service';

describe('FileController Layer1', () => {
  let controller: FileController;
  let fileService: jest.Mocked<FileService>;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [FileController],
      providers: [
        {
          provide: FileService,
          useValue: {
            getFileById: jest.fn(),
            getFilesBySpaceId: jest.fn(),
            createFile: jest.fn(),
            deleteFile: jest.fn(),
            updateFile: jest.fn(),
          },
        },
      ],
    }).compile();

    controller = module.get(FileController);
    fileService = module.get(FileService);
  });

  it('getFile returns file payload and ownership flag', async () => {
    fileService.getFileById.mockResolvedValue({
      file: { id: 'file-1', userId: 'user-1', name: 'notes.pdf' },
      url: '/tmp/notes.pdf',
    } as any);

    const result = await controller.getFile('file-1', { user: { userId: 'user-1' } });
    expect(result).toEqual({
      isOwner: true,
      file: {
        file: { id: 'file-1', userId: 'user-1', name: 'notes.pdf' },
        url: '/tmp/notes.pdf',
      },
    });
  });

  it('getFiles returns list payload and ownership flag', async () => {
    fileService.getFilesBySpaceId.mockResolvedValue([
      { file: { id: 'file-1', userId: 'user-1', name: 'notes.pdf' }, url: '/tmp/notes.pdf' },
    ] as any);

    const result = await controller.getFiles('space-1', { user: { userId: 'user-1' } });
    expect(result.isOwner).toBe(true);
    expect(result.files).toHaveLength(1);
  });

  it('uploadFile forwards uploaded file, userId, and studySpaceId', async () => {
    const uploadedFile = { originalname: 'notes.pdf', buffer: Buffer.from('abc') } as Express.Multer.File;
    fileService.createFile.mockResolvedValue({ file: { id: 'file-1' }, url: '/tmp/notes.pdf' } as any);

    await expect(
      controller.uploadFile(uploadedFile, { user: { userId: 'user-1' } }, { studySpaceId: 'space-1' }),
    ).resolves.toEqual({ file: { id: 'file-1' }, url: '/tmp/notes.pdf' });

    expect(fileService.createFile).toHaveBeenCalledWith(uploadedFile, 'user-1', 'space-1');
  });

  it('throws NotFoundException when request has no authenticated user', async () => {
    await expect(controller.getFile('file-1', { user: undefined })).rejects.toBeInstanceOf(NotFoundException);
  });
});
