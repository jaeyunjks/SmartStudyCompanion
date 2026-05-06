import { Global, Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { LocalStorageRepository } from './local-file-storage.repository';

@Global()
@Module({
    imports: [
        ConfigModule,
    ],
    providers: [
        {
            provide: 'STORAGE_REPOSITORY',
            useClass: LocalStorageRepository,
        },
    ],
    exports: [
        'STORAGE_REPOSITORY',
    ],
})
export class StorageModule {}
