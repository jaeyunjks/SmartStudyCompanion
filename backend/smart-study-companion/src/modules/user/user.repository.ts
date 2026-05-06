export interface UserRepository {
    create(email: string, password: string, fullname: string, username: string): Promise<any>;
    findByEmail(email: string): Promise<any>;
    findByUsername(username: string): Promise<any>;
    findById(id: string): Promise<any>;
    updateById(id: string, fullname?: string): Promise<any>;
    updateByUsername(username: string, fullname?: string, updatedUsername?: string): Promise<any>;
    updateSessionVersion(id: string): Promise<any>;
    validateSessionVersion(id: string, sessionVersion: number): Promise<boolean>;
    resetPassword(id: string, password: string): Promise<any>;
}