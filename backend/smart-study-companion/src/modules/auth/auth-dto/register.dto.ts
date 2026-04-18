import { IsEmail, IsString, MinLength } from 'class-validator';

export class RegisterDto {
    @IsEmail()
    email: string;

    @MinLength(6)
    password: string;

    @MinLength(6)
    confirmPassword: string;

    @IsString()
    fullname: string;

    @IsString()
    username: string;
}
