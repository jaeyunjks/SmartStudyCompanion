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
import { ImageService } from './image.service';
import { JwtAuthGuard } from '../auth/jwt.guard';

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

        const image = await this.imageService.getImagesBySpaceId(id);

        if (!image) {
            throw new NotFoundException("Image not found", "Image not found");
        }

        const isOwner = (userId === image[0].image.userId);

        return {
            isOwner,
            image,
        }
    }

    @UseGuards(JwtAuthGuard)
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

        const createdImages = images.map(async (image: any) => {
            const createdImage = await this.imageService.createImage(image, userId, data.studySpaceId);
            
            if (!createdImage) {
                throw new InternalServerErrorException("", "Couldn't upload image");
            }

            return createdImage;
        })

        return createdImages;
    }
}
