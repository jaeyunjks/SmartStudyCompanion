import { Injectable, Inject, InternalServerErrorException, NotFoundException } from '@nestjs/common';
import { StudySpaceRepository } from './study-space.repository';

@Injectable()
export class StudySpaceService {
    constructor(
        @Inject('STUDY_SPACE_REPOSITORY')
        private readonly studySpaceRepo: StudySpaceRepository,
    ) {}

    async createStudySpace (title: string, userId: string) {
        const studySpace = await this.studySpaceRepo.create(title, userId);

        if (!studySpace) {
            throw new InternalServerErrorException("Couldn't create study space", "Couldn't create study space");
        }

        return studySpace;
    }

    async updateStudySpaceById (id: string, userId: string, title?: string) {
        const studySpace = await this.studySpaceRepo.updateById(id, userId, title);

        if (!studySpace) {
            throw new InternalServerErrorException("Couldn't update this study space", "Couldn't update this study space");
        }

        return studySpace;
    }

    async deleteStudySpaceById (id: string, userId: string) {
        const studySpace = await this.studySpaceRepo.delete(id, userId);

        if (!studySpace) {
            throw new InternalServerErrorException("Couldn't delete this study space", "Couldn't delete this study space");
        }

        return studySpace;
    }

    async getStudySpaceById (id: string) {
        const studySpace = await this.studySpaceRepo.getById(id);

        if (!studySpace) {
            throw new NotFoundException("Study space not found", "Study space not found");
        }

        return studySpace; 
    }
}
