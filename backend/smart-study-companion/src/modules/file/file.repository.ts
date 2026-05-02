export interface FileRepository {
    create(spaceId: string, name: string, mimeType: string, size: number, userId: string): Promise<any>;
    updateById(id: string, userId: string, name?: string): Promise<any>;
    findById(id: string): Promise<any>;
    findByStudySpaceId(spaceId: string): Promise<any>;
    deleteById(id: string, userId: string): Promise<any>;
}