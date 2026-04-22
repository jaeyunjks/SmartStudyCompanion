import { 
    Controller,
    Get,
    Post,
    Param,
    Body,
    InternalServerErrorException,
    NotFoundException,
    UseGuards,
    Request
} from '@nestjs/common';
import { NoteService } from './note.service';
import { JwtAuthGuard } from '../auth/jwt.guard';
import { AddNoteDto } from './note-dto/add-note.dto';
import { UpdateNoteDto } from './note-dto/update-note.dto';

@Controller('api/note')
export class NoteController {
    constructor (
        private readonly noteService: NoteService,
    ) {}

    @UseGuards(JwtAuthGuard)
    @Get(':id')
    async getNote (
        @Param('id') id: string,
        @Request() req: any,
    ) {
        const user = req.user;
        const userId = user?.userId;

        if (!userId) {
            throw new NotFoundException("User not found", "User not found");
        }

        const note = await this.noteService.getNoteById(id);

        if (!note) {
            throw new NotFoundException("Note not found", "Note not found");
        }

        const isOwner = (userId === note.userId);

        return {
            note,
            isOwner,
        };
    }

    @UseGuards(JwtAuthGuard)
    @Get('study-space/:id')
    async getNotes (
        @Param('id') id: string,
        @Request() req: any,
    ) {
        const user = req.user;
        const userId = user?.userId;

        if (!userId) {
            throw new NotFoundException("User not found", "User not found");
        }

        const notes = await this.noteService.getNotesBySpaceId(id);

        if (!notes) {
            throw new NotFoundException("Notes not found", "Notes not found");
        }

        const isOwner = (userId === notes.userId);

        return {
            notes,
            isOwner,
        };
    }

    @UseGuards(JwtAuthGuard)
    @Post('add')
    async addNote (
        @Request() req: any,
        @Body() addNoteDto: AddNoteDto,
    ) {
        const user = req.user;
        const userId = user?.userId;

        if (!userId) {
            throw new NotFoundException("User not found", "User not found");
        }

        const note = this.noteService.createNote(
            addNoteDto.title,
            addNoteDto.spaceId,
            userId,
            addNoteDto.content,
        );

        if (!note) {
            throw new InternalServerErrorException("Couldn't add note", "Couldn't add note");
        }

        return note;
    }

    @UseGuards(JwtAuthGuard)
    @Post('update')
    async updateNote (
        @Request() req: any,
        @Body() updateNoteDto: UpdateNoteDto,
    ) {
        const user = req.user;
        const userId = user?.userId;

        if (!userId) {
            throw new NotFoundException("User not found", "User not found");
        }

        const note = this.noteService.updateNote(
            updateNoteDto.id,
            userId,
            updateNoteDto.title,
            updateNoteDto.content,
        );

        if (!note) {
            throw new InternalServerErrorException("Couldn't update note", "Couldn't update note");
        }

        return note;
    }

    @UseGuards(JwtAuthGuard)
    @Post('delete')
    async deleteNote (
        @Request() req: any,
        @Body() data: {id: string},
    ) {
        const user = req.user;
        const userId = user?.userId;

        if (!userId) {
            throw new NotFoundException("User not found", "User not found");
        }

        const note = this.noteService.deleteNote(data.id, userId);

        if (!note) {
            throw new InternalServerErrorException("Couldn't delete note", "Couldn't delete note");
        }

        return note;
    }
}
