import { 
    Controller, 
    Get, 
    Post, 
    UseGuards,
    Param,
    Request,
    NotFoundException,
    InternalServerErrorException,
    Body,
} from '@nestjs/common';
import { StudySpaceService } from './study-space.service';
import { JwtAuthGuard } from '../auth/jwt.guard';
import { AddStudySpaceDto } from './study-space-dto/add-study-space.dto';
import { UpdateStudySpaceDto } from './study-space-dto/update-study-space.dto';

@Controller('api/study-space')
export class StudySpaceController {
    constructor(
        private readonly studySpaceService: StudySpaceService,
    ) {}

    @UseGuards(JwtAuthGuard)
    @Get(':id')
    async getStudySpace (
        @Param('id') id: string,
        @Request() req: any,
    ) {
        const user = req.user;
        const userId = user?.userId;

        if (!userId) {
            throw new NotFoundException("User not found", "User not found");
        }

        const studySpace = await this.studySpaceService.getStudySpaceById(id);

        if (!studySpace) {
            throw new NotFoundException("Study space not found", "Study space not found");
        }

        const isOwner = (userId === studySpace.userId);

        return {
            isOwner,
            studySpace,
        };
    }

    @UseGuards(JwtAuthGuard)
    @Get('user/:id')
    async getStudySpaces (
        @Param('id') id: string,
        @Request() req: any,
    ) {
        const user = req.user;
        const userId = user?.userId;

        if (!userId) {
            throw new NotFoundException("User not found", "User not found");
        }

        const studySpaces = await this.studySpaceService.getStudySpacesByUserId(id);

        if (!studySpaces) {
            throw new NotFoundException("Study spaces not found", "Study spaces not found");
        }

        const isOwner = (userId === id);

        return {
            isOwner,
            studySpaces,
        };
    }

    @UseGuards(JwtAuthGuard)
    @Post('add')
    async addStudySpace (
        @Body() addStudySpaceDto: AddStudySpaceDto,
        @Request() req: any,
    ) {
        const user = req.user;
        const userId = user?.userId;

        if (!userId) {
            throw new NotFoundException("User not found", "User not found");
        }

        const studySpace = await this.studySpaceService.createStudySpace(addStudySpaceDto.title, userId);

        if (!studySpace) {
            throw new InternalServerErrorException("Couldn't create study space", "Couldn't create study space");
        }

        return studySpace;
    }

    @UseGuards(JwtAuthGuard)
    @Post('update')
    async updateStudySpace (
        @Body() updateStudySpaceDto: UpdateStudySpaceDto,
        @Request() req: any,
    ) {
        const user = req.user;
        const userId = user?.userId;

        if (!userId) {
            throw new NotFoundException("User not found", "User not found");
        }

        const studySpace = await this.studySpaceService.updateStudySpaceById(updateStudySpaceDto.id, userId, updateStudySpaceDto.title);

        if (!studySpace) {
            throw new InternalServerErrorException("Couldn't update study space", "Couldn't update study space");
        }

        return studySpace;
    }

    @UseGuards(JwtAuthGuard)
    @Post('delete')
    async deleteStudySpace (
        @Body() data: {id: string},
        @Request() req: any,
    ) {
        const user = req.user;
        const userId = user?.userId;

        if (!userId) {
            throw new NotFoundException("User not found", "User not found");
        }

        const studySpace = await this.studySpaceService.deleteStudySpaceById(data.id, userId);

        if (!studySpace) {
            throw new InternalServerErrorException("Couldn't delete this study space", "Couldn't delete this study space");
        }

        return studySpace;
    }
}
