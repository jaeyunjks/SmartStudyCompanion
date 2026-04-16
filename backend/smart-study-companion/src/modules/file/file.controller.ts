import { 
    Controller,
    Get,
    Post,
    UseGuards,
    NotFoundException,
    InternalServerErrorException,
    Param,
    Body,
    Request,
    UploadedFile,
    UploadedFiles,
} from '@nestjs/common';
import { FileService } from './file.service';
import { JwtAuthGuard } from '../auth/jwt.guard';

@Controller('api/file')
export class FileController {
    constructor(
        private readonly fileService: FileService,
    ) {}

    @UseGuards(JwtAuthGuard)
    @Get(':id')
    async getFile (
        @Param('id') id: string,
        @Request() req: any,
    ) {
        const user = req.user;
        const userId = user?.userId;

        if (!userId) {
            throw new NotFoundException("User not found", "User not found");
        }

        const file = await this.fileService.getFileById(id);

        if (!file) {
            throw new NotFoundException("File not found", "File not found");
        }

        const isOwner = (userId === file.file.userId);

        return {
            isOwner,
            file,
        }
    }

    @UseGuards(JwtAuthGuard)
    @Get('study-space/:id')
    async getFiles (
        @Param('id') id: string,
        @Request() req: any,
    ) {
        const user = req.user;
        const userId = user?.userId;

        if (!userId) {
            throw new NotFoundException("User not found", "User not found");
        }

        const file = await this.fileService.getFilesBySpaceId(id);

        if (!file) {
            throw new NotFoundException("File not found", "File not found");
        }

        const isOwner = (userId === file[0].file.userId);

        return {
            isOwner,
            file,
        }
    }

    @UseGuards(JwtAuthGuard)
    @Post('add-one')
    async uploadFile (
        @UploadedFile() file: Express.Multer.File,
        @Request() req: any,
        @Body() data: { studySpaceId: string }
    ) {
        const user = req.user;
        const userId = user?.userId;

        if (!userId) {
            throw new NotFoundException("User not found", "User not found");
        }

        const createdFile = await this.fileService.createFile(file, userId, data.studySpaceId);

        if (!createdFile) {
            throw new InternalServerErrorException("", "Couldn't upload file");
        }

        return createdFile;
    }

    @UseGuards(JwtAuthGuard)
    @Post('add-many')
    async uploadFiles (
        @UploadedFiles() files: Express.Multer.File[],
        @Request() req: any,
        @Body() data: { studySpaceId: string }
    ) {
        const user = req.user;
        const userId = user?.userId;

        if (!userId) {
            throw new NotFoundException("User not found", "User not found");
        }

        const createdFiles = files.map(async (file: any) => {
            const createdFile = await this.fileService.createFile(file, userId, data.studySpaceId);
            
            if (!createdFile) {
                throw new InternalServerErrorException("", "Couldn't upload file");
            }

            return createdFile;
        })

        return createdFiles;
    }
}
