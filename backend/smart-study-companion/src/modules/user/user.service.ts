import { Injectable, Inject, InternalServerErrorException } from '@nestjs/common';
import { UserRepository } from './user.repository';
// import { FolderService } from '../folder/folder.service';

@Injectable()
export class UserService {
    constructor(
        @Inject('USER_REPOSITORY')
        private readonly userRepo: UserRepository,
        // private folderService: FolderService,
    ) {}

    async createUser(email: string, password: string, fullname: string, username: string) {
        const user = await this.userRepo.create( email, password, fullname, username );

        if (!user) { 
            throw new InternalServerErrorException("Couldn't create user");
        }

        // const accountRootFolder = await this.folderService.createFolder(user.id, user.username);
        // const accountFreeFolder = await this.folderService.createFolder(user.id, "free", accountRootFolder.id);

        // if (!accountRootFolder || !accountFreeFolder) {
        //     throw new InternalServerErrorException("Couldn't create folders");
        // }

        return user;
    }

    async getUserByEmail(email: string) {
        return this.userRepo.findByEmail(email);
    }

    async getUserByUsername(username: string) {
        return this.userRepo.findByUsername(username);
    }

    async getUserById(id: string) {
        return this.userRepo.findById(id);
    }

    async updateSessionVersion(id: string) {
        return this.userRepo.updateSessionVersion(id);
    }

    async validateSessionVersion(id: string, sessionVersion: number) {
        return this.userRepo.validateSessionVersion(id, sessionVersion);
    }

    async resetPassword(id: string, password: string) {
        return this.userRepo.resetPassword(id, password);
    }

    async updateProfileById(id: string, fullname?: string) {
        return this.userRepo.updateById(id, fullname);
    }

    async updateProfileByUsername(username: string, fullname?: string, updatedUsername?: string) {
        return this.userRepo.updateByUsername(username, fullname, updatedUsername);
    }
}
