import { 
    Injectable, 
    Inject, 
    InternalServerErrorException, 
    NotFoundException 
} from '@nestjs/common';
import { FileRepository } from './file.repository';
import { StudySpaceService } from '../study-space/study-space.service';
import * as fs from 'fs/promises';
import * as path from 'path';
import { UserService } from '../user/user.service';

@Injectable()
export class FileService {
    constructor (
        @Inject('FILE_REPOSITORY')
        private readonly fileRepo: FileRepository,
        private readonly studySpaceService: StudySpaceService,
        private readonly userService: UserService,
    ) {}

    private rootFolder = process.env.STORAGE_URL as string;
    private fileFolder = process.env.FILE_STORAGE_URL as string;

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

        // Folder URL would be blob/username/spaceTitle
        const folderUrl = path.join(this.rootFolder, owner.username, studySpace.title, this.fileFolder);
        
        // Create folders if not exists
        await fs.mkdir(folderUrl, { recursive: true })

        // File URL would be blob/username/spaceTitle/filename
        const url = path.join(folderUrl, originalname);

        await fs.writeFile(url, buffer);

        return {
            file,
            url,
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

        const filePath = path.join(this.rootFolder, owner.username, studySpace.title, this.fileFolder, file.name);
        
        await fs.rm(filePath, { force: true });

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

        const folderUrl = path.join(this.rootFolder, owner.username, studySpace.title, this.fileFolder);

        const oldPath = path.join(folderUrl, oldFile.name);
        const newPath = path.join(folderUrl, newFileName);

        await fs.rename(oldPath, newPath);

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

        const url = path.join(this.rootFolder, owner.username, studySpace.title, this.fileFolder, file.name);
        
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

        const folderUrl = path.join(this.rootFolder, owner.username, studySpace.title, this.fileFolder);

        const response = files.map((file: any) => {
            const url = path.join(folderUrl, file.name);
            return {
                file,
                url,
            };
        });
        // Return a list of files with their URLs
        return response;
    }
}