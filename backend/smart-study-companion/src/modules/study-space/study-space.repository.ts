export interface StudySpaceRepository {
    create(title: string, userId: string): Promise<any>;
    updateById(id: string, userId: string, title?: string): Promise<any>;
    delete(id: string, userId: string): Promise<any>;
    getById(id: string): Promise<any>;
}