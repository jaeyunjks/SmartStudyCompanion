export type StorageFolder = 'file' | 'image';

export type StorageObjectInput = {
    ownerName: string;
    studySpaceTitle: string;
    folder: StorageFolder;
    fileName: string;
};

export type UploadStorageObjectInput = StorageObjectInput & {
    buffer: Buffer;
};

export interface StorageRepository {
    upload(input: UploadStorageObjectInput): Promise<string>;
    delete(input: StorageObjectInput): Promise<void>;
    move(from: StorageObjectInput, to: StorageObjectInput): Promise<string>;
    getUrl(input: StorageObjectInput): string;
    readText(storageKey: string): Promise<string>;
    readBuffer(storageKey: string): Promise<Buffer>;
}
