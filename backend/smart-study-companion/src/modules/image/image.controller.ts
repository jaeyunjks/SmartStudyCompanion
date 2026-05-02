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
import { ImageService } from './image.service';
import { JwtAuthGuard } from '../auth/jwt.guard';
import { UpdateImageDto } from './image-dto/update-image.dto';

@Controller('api/image')
export class ImageController {
    constructor(
        private readonly imageService: ImageService,
    ) {}

    @UseGuards(JwtAuthGuard)
    @Get(':id')
    async getImage (
        @Param('id') id: string,
        @Request() req: any,
    ) {
        const user = req.user;
        const userId = user?.userId;

        if (!userId) {
            throw new NotFoundException("User not found", "User not found");
        }

        const image = await this.imageService.getImageById(id);

        if (!image) {
            throw new NotFoundException("Image not found", "Image not found");
        }

        const isOwner = (userId === image.image.userId);

        return {
            isOwner,
            image,
        }
    }

    @UseGuards(JwtAuthGuard)
    @Get('study-space/:id')
    async getImages (
        @Param('id') id: string,
        @Request() req: any,
    ) {
        const user = req.user;
        const userId = user?.userId;

        if (!userId) {
            throw new NotFoundException("User not found", "User not found");
        }

        const images = await this.imageService.getImagesBySpaceId(id);

        if (!images) {
            throw new NotFoundException("Image not found", "Image not found");
        }

        const isOwner = (userId === images[0].image.userId);

        return {
            isOwner,
            images,
        }
    }

    @UseGuards(JwtAuthGuard)
    @UseInterceptors(FileInterceptor('image'))
    @Post('add-one')
    async uploadImage (
        @UploadedFile() image: Express.Multer.File,
        @Request() req: any,
        @Body() data: { studySpaceId: string }
    ) {
        const user = req.user;
        const userId = user?.userId;

        if (!userId) {
            throw new NotFoundException("User not found", "User not found");
        }

        const createdImage = await this.imageService.createImage(image, userId, data.studySpaceId);

        if (!createdImage) {
            throw new InternalServerErrorException("", "Couldn't upload image");
        }

        return createdImage;
    }

    @UseGuards(JwtAuthGuard)
    @UseInterceptors(FilesInterceptor('images'))
    @Post('add-many')
    async uploadFiles (
        @UploadedFiles() images: Express.Multer.File[],
        @Request() req: any,
        @Body() data: { studySpaceId: string }
    ) {
        const user = req.user;
        const userId = user?.userId;

        if (!userId) {
            throw new NotFoundException("User not found", "User not found");
        }

        const createdImages = await Promise.all(
                images.map(async (image: any) => {
                const createdImage = await this.imageService.createImage(image, userId, data.studySpaceId);
                
                if (!createdImage) {
                    throw new InternalServerErrorException("", "Couldn't upload image");
                }

                return createdImage;
            })
        );

        return createdImages;
    }

    @UseGuards(JwtAuthGuard)
    @Post('delete')
    async deleteImage (
        @Request() req: any,
        @Body() data: {id: string},
    ) {
        const user = req.user;
        const userId = user?.userId;

        if (!userId) {
            throw new NotFoundException("User not found", "User not found");
        }

        const image = await this.imageService.deleteImage(data.id, userId);

        if (!image) {
            throw new InternalServerErrorException("Couldn't delete the image", "Couldn't delete the image");
        }

        return image;
    }

    @UseGuards(JwtAuthGuard)
    @Post('update')
    async updateImage (
        @Request() req: any,
        @Body() updateImageDto: UpdateImageDto,
    ) {
        const user = req.user;
        const userId = user?.userId;

        if (!userId) {
            throw new NotFoundException("User not found", "User not found");
        }

        const image = await this.imageService.updateImage(updateImageDto.id, userId, updateImageDto.name);

        if (!image) {
            throw new InternalServerErrorException("Couldn't update the image", "Couldn't update the image");
        }

        return image;
    }
}
