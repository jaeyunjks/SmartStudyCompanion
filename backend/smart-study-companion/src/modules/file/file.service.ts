import { 
    Injectable, 
    Inject, 
    InternalServerErrorException, 
    NotFoundException,
    forwardRef,
} from '@nestjs/common';
import { FileRepository } from './file.repository';
import { StudySpaceService } from '../study-space/study-space.service';
import * as path from 'path';
import { UserService } from '../user/user.service';
import { AiEmbeddingService } from '../ai/ai-embedding.service';
import { StorageRepository } from '../file-storage/file-storage.repository';

@Injectable()
export class FileService {
    constructor (
        @Inject('FILE_REPOSITORY')
        private readonly fileRepo: FileRepository,
        private readonly studySpaceService: StudySpaceService,
        private readonly userService: UserService,
        @Inject(forwardRef(() => AiEmbeddingService))
        private readonly aiEmbeddingService: AiEmbeddingService,
        @Inject('STORAGE_REPOSITORY')
        private readonly storageRepo: StorageRepository,
    ) {}

    async createFile (uploadedFile: Express.Multer.File, userId: string, studySpaceId: string) {
        const { originalname, mimetype, size, buffer } = uploadedFile;
        const owner = await this.userService.getUserById(userId);
        const studySpace = await this.studySpaceService.getStudySpaceById(studySpaceId);

        if (!owner) {
            throw new NotFoundException("User not found", "User not found");
        }  
        
        if (!studySpace) {
            throw new NotFoundException("Study space not found", "Study space not found");
        }

        // Add a file value into the database
        const file = await this.fileRepo.create(studySpaceId, originalname, mimetype, size, userId);

        const url = await this.storageRepo.upload({
            ownerName: owner.username,
            studySpaceTitle: studySpace.title,
            folder: 'file',
            fileName: originalname,
            buffer,
        });

        const embeddingResult = await this.aiEmbeddingService.chunkAndEmbedUploadedFile(file, buffer);

        return {
            file,
            url,
            embeddingResult,
        };
    }

    async deleteFile (fileId: string, userId: string) {
        const file = await this.fileRepo.deleteById(fileId, userId);

        if (!file) {
            throw new NotFoundException("","File not found");
        }

        const owner = await this.userService.getUserById(userId);
        const studySpace = await this.studySpaceService.getStudySpaceById(file.spaceId);

       if (!owner) {
            throw new NotFoundException("User not found", "User not found");
        }  
        
        if (!studySpace) {
            throw new NotFoundException("Study space not found", "Study space not found");
        }

        await this.storageRepo.delete({
            ownerName: owner.username,
            studySpaceTitle: studySpace.title,
            folder: 'file',
            fileName: file.name,
        });

        return file;
    }

    async updateFile (fileId: string, userId: string, name?: string) {
        const oldFile = await this.fileRepo.findById(fileId);
        // Extract file extension
        const ext = path.extname(oldFile.name); // ".png", ".pdf", etc.

        const newFileName = name
            ? name.endsWith(ext)
            ? name
            : `${name}${ext}`
            : oldFile.name;

        const updatedFile = await this.fileRepo.updateById(fileId, userId, newFileName);

        const owner = await this.userService.getUserById(userId);
        const studySpace = await this.studySpaceService.getStudySpaceById(updatedFile.spaceId);

       if (!owner) {
            throw new NotFoundException("User not found", "User not found");
        }  
        
        if (!studySpace) {
            throw new NotFoundException("Study space not found", "Study space not found");
        }

        const newPath = await this.storageRepo.move(
            {
                ownerName: owner.username,
                studySpaceTitle: studySpace.title,
                folder: 'file',
                fileName: oldFile.name,
            },
            {
                ownerName: owner.username,
                studySpaceTitle: studySpace.title,
                folder: 'file',
                fileName: newFileName,
            },
        );

        return {
            file: updatedFile,
            url: newPath,
        };
    }

    async getFileById (fileId: string) {
        const file = await this.fileRepo.findById(fileId);

        if (!file) {
            throw new NotFoundException("", "File not found");
        }

        const owner = await this.userService.getUserById(file.userId);
        const studySpace = await this.studySpaceService.getStudySpaceById(file.spaceId);

        if (!owner) {
            throw new NotFoundException("User not found", "User not found");
        }  
        
        if (!studySpace) {
            throw new NotFoundException("Study space not found", "Study space not found");
        }

        const url = this.storageRepo.getUrl({
            ownerName: owner.username,
            studySpaceTitle: studySpace.title,
            folder: 'file',
            fileName: file.name,
        });
        
        return {
            file,
            url,
        };
    }

    async getFilesBySpaceId (spaceId: string) {
        const files = await this.fileRepo.findByStudySpaceId(spaceId);

        if (!files) {
            throw new NotFoundException("Files not found", "Files not found");
        }

        const studySpace = await this.studySpaceService.getStudySpaceById(spaceId);

        if (!studySpace) {
            throw new NotFoundException("Study space not found", "Study space not found");
        }

        const owner = await this.userService.getUserById(studySpace.userId);

        if (!owner) {
            throw new NotFoundException("User not found", "User not found");
        }  

        const response = files.map((file: any) => {
            const url = this.storageRepo.getUrl({
                ownerName: owner.username,
                studySpaceTitle: studySpace.title,
                folder: 'file',
                fileName: file.name,
            });
            return {
                file,
                url,
            };
        });
        // Return a list of files with their URLs
        return response;
    }
}
