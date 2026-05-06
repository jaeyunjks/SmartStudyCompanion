import { 
    Injectable, 
    Inject, 
    InternalServerErrorException, 
    NotFoundException 
} from '@nestjs/common';
import { ImageRepository } from './image.repository';
import { StudySpaceService } from '../study-space/study-space.service';
import * as path from 'path';
import { UserService } from '../user/user.service';
import { StorageRepository } from '../file-storage/file-storage.repository';

@Injectable()
export class ImageService {
    constructor (
        @Inject('IMAGE_REPOSITORY')
        private readonly imageRepo: ImageRepository,
        private readonly studySpaceService: StudySpaceService,
        private readonly userService: UserService,
        @Inject('STORAGE_REPOSITORY')
        private readonly storageRepo: StorageRepository,
    ) {}

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

        const url = await this.storageRepo.upload({
            ownerName: owner.username,
            studySpaceTitle: studySpace.title,
            folder: 'image',
            fileName: originalname,
            buffer,
        });

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

        await this.storageRepo.delete({
            ownerName: owner.username,
            studySpaceTitle: studySpace.title,
            folder: 'image',
            fileName: image.name,
        });

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

        const newPath = await this.storageRepo.move(
            {
                ownerName: owner.username,
                studySpaceTitle: studySpace.title,
                folder: 'image',
                fileName: oldImage.name,
            },
            {
                ownerName: owner.username,
                studySpaceTitle: studySpace.title,
                folder: 'image',
                fileName: newImageName,
            },
        );

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

        const url = this.storageRepo.getUrl({
            ownerName: owner.username,
            studySpaceTitle: studySpace.title,
            folder: 'image',
            fileName: image.name,
        });
        
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

        const response = images.map((image: any) => {
            const url = this.storageRepo.getUrl({
                ownerName: owner.username,
                studySpaceTitle: studySpace.title,
                folder: 'image',
                fileName: image.name,
            });
            return {
                image,
                url,
            };
        });
        // Return a list of images with their URLs
        return response;
    }
}
