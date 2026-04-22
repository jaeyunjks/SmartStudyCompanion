import { 
    Injectable,
    Inject,
    InternalServerErrorException,
} from '@nestjs/common';
import { NoteRepository } from './note.repository';

@Injectable()
export class NoteService {
    constructor (
        @Inject('NOTE_REPOSITORY')
        private readonly noteRepo: NoteRepository,
    ) {}

    async createNote (title: string, spaceId: string, userId: string, content?: any) {
        const note = await this.noteRepo.create(title, spaceId, userId, content);

        if (!note) {
            throw new InternalServerErrorException("Couldn't create note", "Couldn't create note");
        }

        return note;
    }

    async updateNote (id: string, userId: string, title?: string, content?: any) {
        const note = await this.noteRepo.update(id, userId, title, content);

        if (!note) {
            throw new InternalServerErrorException("Couldn't update note", "Couldn't update note");
        }

        return note;
    }

    async deleteNote (id: string, userId: string) {
        const note = await this.noteRepo.delete(id, userId);

        if (!note) {
            throw new InternalServerErrorException("Couldn't delete note", "Couldn't delete note");
        }

        return note;
    }

    async getNoteById (id: string) {
        const note = await this.noteRepo.getById(id);

        if (!note) {
            throw new InternalServerErrorException("Note not found", "Note not found");
        }

        return note;
    }

    async getNotesBySpaceId (spaceId: string) {
        const notes = await this.noteRepo.getBySpaceId(spaceId);

        if (!notes) {
            throw new InternalServerErrorException("Notes not found", "Notes not found");
        }

        return notes;
    }
}
