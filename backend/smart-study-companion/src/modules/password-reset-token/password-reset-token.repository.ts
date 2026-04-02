export interface PasswordResetTokenRepository {
    create(userId: string, token: string, expiresAt: Date): Promise<any>;
    getToken(rawToken: string): Promise<any>;
    useToken(id: string): Promise<any>;
}