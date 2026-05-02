import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as fs from 'fs/promises';
import * as path from 'path';
import {
    StorageObjectInput,
    StorageRepository,
    UploadStorageObjectInput,
} from './file-storage.repository';

@Injectable()
export class LocalStorageRepository implements StorageRepository {
    constructor(
        private readonly configService: ConfigService,
    ) {}

    async upload(input: UploadStorageObjectInput): Promise<string> {
        const storageKey = this.getUrl(input);
        const folderPath = path.dirname(storageKey);

        await fs.mkdir(folderPath, { recursive: true });
        await fs.writeFile(storageKey, input.buffer);

        return storageKey;
    }

    async delete(input: StorageObjectInput): Promise<void> {
        await fs.rm(this.getUrl(input), { force: true });
    }

    async move(from: StorageObjectInput, to: StorageObjectInput): Promise<string> {
        const oldStorageKey = this.getUrl(from);
        const newStorageKey = this.getUrl(to);

        await fs.mkdir(path.dirname(newStorageKey), { recursive: true });
        await fs.rename(oldStorageKey, newStorageKey);

        return newStorageKey;
    }

    getUrl(input: StorageObjectInput): string {
        return path.join(
            this.getRequiredConfig('STORAGE_URL'),
            input.ownerName,
            input.studySpaceTitle,
            this.getFolderName(input.folder),
            input.fileName,
        );
    }

    async readText(storageKey: string): Promise<string> {
        return fs.readFile(storageKey, 'utf8');
    }

    async readBuffer(storageKey: string): Promise<Buffer> {
        return fs.readFile(storageKey);
    }

    private getFolderName(folder: StorageObjectInput['folder']) {
        if (folder === 'file') {
            return this.getRequiredConfig('FILE_STORAGE_URL');
        }

        return this.getRequiredConfig('IMAGE_STORAGE_URL');
    }

    private getRequiredConfig(key: string) {
        const value = this.configService.get<string>(key);

        if (!value) {
            throw new InternalServerErrorException(`${key} is not configured`);
        }

        return value;
    }
}
