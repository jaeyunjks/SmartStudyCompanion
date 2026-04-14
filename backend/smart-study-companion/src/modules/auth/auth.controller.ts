import { Controller, Post, Get, Put, Body, Query } from '@nestjs/common';
import { AuthService } from './auth.service';
import { RegisterDto } from './auth-dto/register.dto';
import { LoginDto } from './auth-dto/login.dto';
import { ChangePasswordDto } from './auth-dto/change-password.dto';
import { ResetPasswordDto } from './auth-dto/reset-password.dto';

@Controller('api/auth')
export class AuthController {
    constructor(private authService: AuthService) {}

    @Post('signup')
    async register(
        @Body() registerDto: RegisterDto
    ) {
        return this.authService.register(registerDto.email, registerDto.password, registerDto.confirmPassword, registerDto.fullname, registerDto.username);
    }

    @Post('login')
    async login(
        @Body() loginDto: LoginDto
    ) {
        return this.authService.login(loginDto.email, loginDto.password);
    }

    @Post('reset-password')
    async changePassword(
        @Body() changePasswordDto: ChangePasswordDto
    ) {
        return this.authService.changePassword(changePasswordDto.email);
    }

    @Get('reset-password')
    async verifyToken(
        @Query('token') token: string,
    ) {
        return this.authService.checkResetToken(token);
    }

    @Put('reset-password')
    async resetPassword( 
        @Body() resetPasswordDto: ResetPasswordDto
    ) {
        return this.authService.resetPassword(resetPasswordDto.password, resetPasswordDto.confirmPassword, resetPasswordDto.token);
    }
}
