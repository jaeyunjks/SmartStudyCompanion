import { Module } from '@nestjs/common';
import { NoteService } from './note.service';
import { NoteController } from './note.controller';
import { PrismaNoteRepository } from 'src/database/prisma/prisma-note.repository';

@Module({
    imports: [

    ],
    providers: [
        NoteService,
        {
            provide: 'NOTE_REPOSITORY',
            useClass: PrismaNoteRepository,
        },
    ],
    controllers: [
        NoteController,
    ],
    exports: [
        NoteService,
    ],
})
export class NoteModule {}
