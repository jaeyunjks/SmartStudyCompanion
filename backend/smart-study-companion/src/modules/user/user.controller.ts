import { Controller, Get, Param, UseGuards, Request, NotFoundException, Post, Body, UnauthorizedException } from '@nestjs/common';
import { UserService } from './user.service';
import { OptionalJwtAuthGuard } from '../auth/optional-jwt.guard';
import { JwtAuthGuard } from '../auth/jwt.guard';
import { UpdateUserDto } from './user-dto/update-user.dto';

@Controller('api/user')
export class UserController {
    constructor(
        private readonly userService: UserService,
    ) {}

    @UseGuards(OptionalJwtAuthGuard)
    @Get(':username')
    async getProfile(
        @Param('username') username: string,
        @Request() req: any,
    ) {
        const viewer = req.user; // This will be undefined if the user is not authenticated

        const profile = await this.userService.getUserByUsername(username);

        if (!profile) {
            throw new NotFoundException('User not found');
        }

        return {
            profile: this.serializeProfile(profile),
            viewerId: viewer?.userId,
            profileId: profile.id,
        };
    }

    @UseGuards(JwtAuthGuard)
    @Post(':username')
    async editProfile(
        @Param('username') username: string,
        @Request() req: any,
        @Body() updateUserDto: UpdateUserDto,
    ) {
        const viewer = req.user; // This will be undefined if the user is not authenticated
        const profile = await this.userService.getUserByUsername(username);

        if (!viewer) {
            throw new UnauthorizedException("User not found");
        }

        if(!profile) {
            throw new NotFoundException("Profile not found");
        }

        if (viewer.userId != profile.id) {
            throw new UnauthorizedException("Not allowed to edit other user's profile.");
        }

        const updatedProfile = await this.userService.updateProfileByUsername(
            username,
            updateUserDto.fullname,
            updateUserDto.username,
            updateUserDto.profileImage,
        );

        return this.serializeProfile(updatedProfile);
    }

    private serializeProfile(user: any) {
        return {
            id: user.id,
            email: user.email,
            fullname: user.fullname,
            username: user.username,
            profileImage: user.profileImage,
            createdAt: user.createdAt,
        };
    }
}
