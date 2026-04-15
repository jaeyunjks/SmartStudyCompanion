import { MinLength, IsString } from 'class-validator';

export class ResetPasswordDto {
    @MinLength(6)
    password: string;

    @MinLength(6)
    confirmPassword: string;

    @IsString()
    token: string;
}
