import { 
    Injectable, 
    Inject, 
    InternalServerErrorException, 
    NotFoundException 
} from '@nestjs/common';
import { ImageRepository } from './image.repository';
import { StudySpaceService } from '../study-space/study-space.service';
import * as fs from 'fs/promises';
import * as path from 'path';
import { UserService } from '../user/user.service';

@Injectable()
export class ImageService {
    constructor (
        @Inject('IMAGE_REPOSITORY')
        private readonly imageRepo: ImageRepository,
        private readonly studySpaceService: StudySpaceService,
        private readonly userService: UserService,
    ) {}

    private rootFolder = process.env.STORAGE_URL as string;
    private imageFolder = process.env.IMAGE_STORAGE_URL as string;

    async createImage (uploadedImage: Express.Multer.File, userId: string, studySpaceId: string) {
        const { originalname, mimetype, size, buffer } = uploadedImage;
        const owner = await this.userService.getUserById(userId);
        const studySpace = await this.studySpaceService.getStudySpaceById(studySpaceId);

        if (!owner) {
            throw new NotFoundException("User not found", "User not found");
        }  
        
        if (!studySpace) {
            throw new NotFoundException("Study space not found", "Study space not found");
        }

        // Add a image value into the database
        const image = await this.imageRepo.create(studySpaceId, originalname, mimetype, size, userId);

        // Folder URL would be blob/username/spaceTitle
        const folderUrl = path.join(this.rootFolder, owner.username, studySpace.title, this.imageFolder);
        
        // Create folders if not exists
        await fs.mkdir(folderUrl, { recursive: true })

        // Image URL would be blob/username/spaceTitle/imageName
        const url = path.join(folderUrl, originalname);

        await fs.writeFile(url, buffer);

        return {
            image,
            url,
        };
    }

    async deleteImage (imageId: string, userId: string) {
        const image = await this.imageRepo.deleteById(imageId, userId);

        if (!image) {
            throw new NotFoundException("Image not found","Image not found");
        }

        const owner = await this.userService.getUserById(userId);
        const studySpace = await this.studySpaceService.getStudySpaceById(image.spaceId);

       if (!owner) {
            throw new NotFoundException("User not found", "User not found");
        }  
        
        if (!studySpace) {
            throw new NotFoundException("Study space not found", "Study space not found");
        }

        const imagePath = path.join(this.rootFolder, owner.username, studySpace.title, this.imageFolder, image.name);
        
        await fs.rm(imagePath, { force: true });

        return image;
    }

    async updateImage (imageId: string, userId: string, name?: string) {
        const oldImage = await this.imageRepo.findById(imageId);
        // Extract image extension
        const ext = path.extname(oldImage.name); // ".png", ".pdf", etc.

        const newImageName = name
            ? name.endsWith(ext)
            ? name
            : `${name}${ext}`
            : oldImage.name;

        const updatedImage = await this.imageRepo.updateById(imageId, userId, newImageName);

        const owner = await this.userService.getUserById(userId);
        const studySpace = await this.studySpaceService.getStudySpaceById(updatedImage.spaceId);

       if (!owner) {
            throw new NotFoundException("User not found", "User not found");
        }  
        
        if (!studySpace) {
            throw new NotFoundException("Study space not found", "Study space not found");
        }

        const folderUrl = path.join(this.rootFolder, owner.username, studySpace.title, this.imageFolder);

        const oldPath = path.join(folderUrl, oldImage.name);
        const newPath = path.join(folderUrl, newImageName);

        await fs.rename(oldPath, newPath);

        return {
            image: updatedImage,
            url: newPath,
        };
    }

    async getImageById (imageId: string) {
        const image = await this.imageRepo.findById(imageId);

        if (!image) {
            throw new NotFoundException("", "Image not found");
        }

        const owner = await this.userService.getUserById(image.userId);
        const studySpace = await this.studySpaceService.getStudySpaceById(image.spaceId);

        if (!owner) {
            throw new NotFoundException("User not found", "User not found");
        }  
        
        if (!studySpace) {
            throw new NotFoundException("Study space not found", "Study space not found");
        }

        const url = path.join(this.rootFolder, owner.username, studySpace.title, this.imageFolder, image.name);
        
        return {
            image,
            url,
        };
    }

    async getImagesBySpaceId (spaceId: string) {
        const images = await this.imageRepo.findByStudySpaceId(spaceId);

        if (!images) {
            throw new NotFoundException("Images not found", "Images not found");
        }

        const studySpace = await this.studySpaceService.getStudySpaceById(spaceId);

        if (!studySpace) {
            throw new NotFoundException("Study space not found", "Study space not found");
        }

        const owner = await this.userService.getUserById(studySpace.userId);

        if (!owner) {
            throw new NotFoundException("User not found", "User not found");
        }  

        const folderUrl = path.join(this.rootFolder, owner.username, studySpace.title, this.imageFolder);

        const response = images.map((image: any) => {
            const url = path.join(folderUrl, image.name);
            return {
                image,
                url,
            };
        });
        // Return a list of images with their URLs
        return response;
    }
}