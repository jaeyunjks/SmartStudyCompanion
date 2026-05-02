export interface StudySpaceRepository {
    create(title: string, userId: string, color?: string, tag?: string): Promise<any>;
    updateById(id: string, userId: string, title?: string, color?: string, tag?: string): Promise<any>;
    updateSummaryById(id: string, userId: string, summary: any): Promise<any>;
    delete(id: string, userId: string): Promise<any>;
    getById(id: string): Promise<any>;
    getByUserId(userId: string): Promise<any>;
}
