import { Test, TestingModule } from '@nestjs/testing';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';

describe('AuthController Layer1', () => {
  let controller: AuthController;
  let authService: jest.Mocked<AuthService>;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [AuthController],
      providers: [
        {
          provide: AuthService,
          useValue: {
            register: jest.fn(),
            login: jest.fn(),
            changePassword: jest.fn(),
            checkResetToken: jest.fn(),
            resetPassword: jest.fn(),
          },
        },
      ],
    }).compile();

    controller = module.get(AuthController);
    authService = module.get(AuthService);
  });

  it('register forwards signup payload to AuthService', async () => {
    authService.register.mockResolvedValue({ access_token: 'token-1' } as any);

    const dto = {
      email: 'student@example.com',
      password: 'Password123',
      confirmPassword: 'Password123',
      fullname: 'Thanh Lam Nguyen',
      username: 'thanhlam',
    };

    await expect(controller.register(dto)).resolves.toEqual({ access_token: 'token-1' });
    expect(authService.register).toHaveBeenCalledWith(
      'student@example.com',
      'Password123',
      'Password123',
      'Thanh Lam Nguyen',
      'thanhlam',
    );
  });

  it('login forwards credentials to AuthService', async () => {
    authService.login.mockResolvedValue({ access_token: 'token-2' } as any);

    await expect(controller.login({ email: 'student@example.com', password: 'Password123' })).resolves.toEqual({ access_token: 'token-2' });
    expect(authService.login).toHaveBeenCalledWith('student@example.com', 'Password123');
  });

  it('verifyToken passes query token to AuthService', async () => {
    authService.checkResetToken.mockResolvedValue({ id: 'user-1' } as any);

    await expect(controller.verifyToken('reset-token')).resolves.toEqual({ id: 'user-1' });
    expect(authService.checkResetToken).toHaveBeenCalledWith('reset-token');
  });
});
