import { Injectable, UnauthorizedException, RequestTimeoutException, InternalServerErrorException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { UserService } from '../user/user.service';
import { MailService } from '../mail/mail.service';
import { PasswordResetTokenService } from '../password-reset-token/password-reset-token.service';
import * as bcrypt from 'bcrypt';
import * as crypto from 'crypto';

@Injectable()
export class AuthService {
    constructor(
        private userService: UserService,
        private jwtService: JwtService,
        private mailService: MailService,
        private passwordResetTokenService: PasswordResetTokenService,
    ) {}

    async login(email: string, password: string) {
        let user = await this.validateUser(email, password);

        user = await this.userService.updateSessionVersion(user.id);

        const payload = { sub: user.id, email: user.email, sessionVersion: user.sessionVersion };

        return {
            access_token: this.jwtService.sign(payload),
        };
    }

    async register(email: string, password: string, confirmPassword: string, fullname: string, username: string) {
        if (await this.userService.getUserByEmail(email)) {
            throw new UnauthorizedException('Email already in use');
        }

        if (password !== confirmPassword) {
            throw new UnauthorizedException('Passwords do not match');
        }

        const hashedPassword = await bcrypt.hash(password, 10);
        const user = await this.userService.createUser(email, hashedPassword, fullname, username);

        if (!user) {
            throw new InternalServerErrorException("Couldn't register new user");
        }

        const payload = { sub: user.id, email: user.email, sessionVersion: user.sessionVersion };

        return {
            access_token: this.jwtService.sign(payload),
        };
    }

    async changePassword(email: string) {
        const user = await this.userService.getUserByEmail(email);
        
        if (!user) {
           throw new UnauthorizedException('Invalid email, please try again');
        }

        const rawToken = crypto.randomBytes(32).toString('hex');
        const hashedToken = await bcrypt.hash(rawToken, 10);

        await this.passwordResetTokenService.createPasswordResetToken(user.id, hashedToken);
        await this.mailService.sendPasswordReset(email, rawToken);

        return {
            success_message: 'The password reset link has been sent to your email'
        };
    }

    async checkResetToken (token: string) {
        const resetToken = await this.passwordResetTokenService.getPasswordResetToken(token);

        if (!resetToken) {
            throw new RequestTimeoutException('This reset password link is invalid. It may has been used already or expired.');
        }

        const user = await this.userService.getUserById(resetToken.userId);

        return user;
    }

    async resetPassword (password: string, confirmPassword: string, token: string) {
        const resetToken = await this.passwordResetTokenService.getPasswordResetToken(token);

        if (!resetToken) {
            throw new RequestTimeoutException('This reset password link is invalid. It may has been used already or expired.');
        }

        if (password !== confirmPassword) {
            throw new UnauthorizedException('Passwords do not match');
        }

        // Reset user password
        const hashedPassword = await bcrypt.hash(password, 10);
        let user = await this.userService.resetPassword(resetToken.userId, hashedPassword);

        if (!user) {
            throw new InternalServerErrorException("Internal Error");
        }

        // Update reset password token to be used
        await this.passwordResetTokenService.usePasswordResetToken(resetToken.id);

        user = await this.userService.updateSessionVersion(user.id);

        const payload = { sub: user.id, email: user.email, sessionVersion: user.sessionVersion };

        return {
            access_token: this.jwtService.sign(payload),
        };
    }

    private async validateUser(email: string, password: string) {
        const user = await this.userService.getUserByEmail(email);
        if (!user) {
            throw new UnauthorizedException("Invalid email or password");
        }

        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) {
            throw new UnauthorizedException("Invalid email or password");
        }

        return user;
    }
}
