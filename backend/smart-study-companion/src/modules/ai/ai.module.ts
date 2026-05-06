import { Module, forwardRef } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AiController } from './ai.controller';
import { AiService } from './ai.service';
import { AiEmbeddingService } from './ai-embedding.service';
import { StudySpaceModule } from '../study-space/study-space.module';
import { FileModule } from '../file/file.module';
import { ImageModule } from '../image/image.module';
import { UserModule } from '../user/user.module';

@Module({
    imports: [
        ConfigModule,
        forwardRef(() => StudySpaceModule),
        forwardRef(() => FileModule),
        forwardRef(() => ImageModule),
        forwardRef(() => UserModule),
    ],
    controllers: [
        AiController,
    ],
    providers: [
        AiService,
        AiEmbeddingService,
    ],
    exports: [
        AiEmbeddingService,
    ],
})
export class AiModule {}
