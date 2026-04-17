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
    UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor, FilesInterceptor } from '@nestjs/platform-express';
import { FileService } from './file.service';
import { JwtAuthGuard } from '../auth/jwt.guard';
import { UpdateFileDto } from './file-dto/update-file.dto';

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

        const files = await this.fileService.getFileById(id);

        if (!files) {
            throw new NotFoundException("File not found", "File not found");
        }

        const isOwner = (userId === files.file.userId);

        return {
            isOwner,
            files,
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
    @UseInterceptors(FileInterceptor('file'))
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

        console.log(data.studySpaceId);

        const createdFile = await this.fileService.createFile(file, userId, data.studySpaceId);

        if (!createdFile) {
            throw new InternalServerErrorException("", "Couldn't upload file");
        }

        return createdFile;
    }

    @UseGuards(JwtAuthGuard)
    @UseInterceptors(FilesInterceptor('files'))
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

        const createdFiles = await Promise.all(
            files.map(async (file: any) => {
                const createdFile = await this.fileService.createFile(file, userId, data.studySpaceId);
                
                if (!createdFile) {
                    throw new InternalServerErrorException("", "Couldn't upload file");
                }

                return createdFile;
            })
        );

        return createdFiles;
    }

    @UseGuards(JwtAuthGuard)
    @Post('delete')
    async deleteFile (
        @Request() req: any,
        @Body() data: { id: string },
    ) {
        const user = req.user;
        const userId = user?.userId;

        if (!userId) {
            throw new NotFoundException("User not found", "User not found");
        }

        console.log(data);

        const file = await this.fileService.deleteFile(data.id, userId);

        if (!file) {
            throw new InternalServerErrorException("Couldn't delete the file", "Couldn't delete the file");
        }

        return file;
    }

    @UseGuards(JwtAuthGuard)
    @Post('update')
    async updateFile (
        @Request() req: any,
        @Body() updateFileDto: UpdateFileDto,
    ) {
        const user = req.user;
        const userId = user?.userId;

        if (!userId) {
            throw new NotFoundException("User not found", "User not found");
        }

        const file = await this.fileService.updateFile(updateFileDto.id, userId, updateFileDto.name);

        if (!file) {
            throw new InternalServerErrorException("Couldn't update the file", "Couldn't update the file");
        }

        return file;
    }
}
