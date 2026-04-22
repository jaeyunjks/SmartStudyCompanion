export interface NoteRepository {
    create(title: string, spaceId: string, userId: string, content?: any): Promise<any>;
    update(id: string, userId: string, title?: string, content?: any): Promise<any>;
    delete(id: string, userId: string): Promise<any>;
    getById(id: string): Promise<any>;
    getBySpaceId(spaceId: string): Promise<any>;
}