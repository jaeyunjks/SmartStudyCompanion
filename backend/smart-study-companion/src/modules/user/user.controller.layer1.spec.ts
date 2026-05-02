import { NotFoundException, UnauthorizedException } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { UserController } from '../src/modules/user/user.controller';
import { UserService } from '../src/modules/user/user.service';

describe('UserController Layer1', () => {
  let controller: UserController;
  let userService: jest.Mocked<UserService>;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [UserController],
      providers: [
        {
          provide: UserService,
          useValue: {
            getUserByUsername: jest.fn(),
            updateProfileByUsername: jest.fn(),
          },
        },
      ],
    }).compile();

    controller = module.get(UserController);
    userService = module.get(UserService);
  });

  it('getProfile returns profile and viewer metadata', async () => {
    userService.getUserByUsername.mockResolvedValue({ id: 'user-1', username: 'thanhlam' } as any);

    const result = await controller.getProfile('thanhlam', { user: { userId: 'viewer-1' } });

    expect(result).toEqual({
      profile: { id: 'user-1', username: 'thanhlam' },
      viewerId: 'viewer-1',
      profileId: 'user-1',
    });
  });

  it('getProfile throws NotFoundException when profile does not exist', async () => {
    userService.getUserByUsername.mockResolvedValue(null as any);
    await expect(controller.getProfile('missing', { user: undefined })).rejects.toBeInstanceOf(NotFoundException);
  });

  it('editProfile updates when viewer owns the profile', async () => {
    userService.getUserByUsername.mockResolvedValue({ id: 'user-1', username: 'thanhlam' } as any);
    userService.updateProfileByUsername.mockResolvedValue({ id: 'user-1', username: 'updated' } as any);

    const result = await controller.editProfile(
      'thanhlam',
      { user: { userId: 'user-1' } },
      { fullname: 'Thanh Lam Nguyen', username: 'updated' },
    );

    expect(result).toEqual({ id: 'user-1', username: 'updated' });
    expect(userService.updateProfileByUsername).toHaveBeenCalledWith('thanhlam', 'Thanh Lam Nguyen', 'updated');
  });

  it('editProfile throws UnauthorizedException when viewer is not owner', async () => {
    userService.getUserByUsername.mockResolvedValue({ id: 'user-1', username: 'thanhlam' } as any);

    await expect(
      controller.editProfile('thanhlam', { user: { userId: 'user-2' } }, { fullname: 'Test', username: 'other' }),
    ).rejects.toBeInstanceOf(UnauthorizedException);
  });
});
