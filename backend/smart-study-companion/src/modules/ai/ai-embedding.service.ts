import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import OpenAI from 'openai';
import { PDFParse } from 'pdf-parse';
import { PrismaService } from '../../prisma/prisma.service';

type FileForEmbedding = {
    id: string;
    name: string;
    mimeType: string;
    spaceId: string;
};

type ChunkInput = {
    content: string;
    chunkIndex: number;
    startChar: number;
    endChar: number;
};

@Injectable()
export class AiEmbeddingService {
    private openai?: OpenAI;
    private readonly chunkSize = 500;
    private readonly chunkOverlap = 50;
    private readonly embeddingBatchSize = 100;

    constructor(
        private readonly configService: ConfigService,
        private readonly prisma: PrismaService,
    ) {}

    async chunkAndEmbedUploadedFile(file: FileForEmbedding, buffer: Buffer) {
        const text = await this.extractText(file, buffer);

        if (!text.trim()) {
            return {
                chunksCreated: 0,
                embeddingsCreated: 0,
                skipped: true,
                reason: 'File type is not text-convertible or no text content was found',
            };
        }

        const chunks = this.chunkText(text);

        await this.prisma.chunk.deleteMany({
            where: {
                fileId: file.id,
            },
        });

        await this.prisma.chunk.createMany({
            data: chunks.map((chunk) => ({
                studySpaceId: file.spaceId,
                fileId: file.id,
                content: chunk.content,
                chunkIndex: chunk.chunkIndex,
                startChar: chunk.startChar,
                endChar: chunk.endChar,
            })),
        });

        const storedChunks = await this.prisma.chunk.findMany({
            where: {
                fileId: file.id,
            },
            orderBy: {
                chunkIndex: 'asc',
            },
        });

        const embeddingModel = this.configService.get<string>('TEXT_EMBEDDING_MODEL') ?? 'text-embedding-3-small';
        let embeddingsCreated = 0;

        for (let index = 0; index < storedChunks.length; index += this.embeddingBatchSize) {
            const batch = storedChunks.slice(index, index + this.embeddingBatchSize);
            const embeddings = await this.getOpenAiClient().embeddings.create({
                model: embeddingModel,
                input: batch.map((chunk) => chunk.content),
            });

            await this.prisma.chunkEmbedding.createMany({
                data: embeddings.data.map((embedding, embeddingIndex) => ({
                    chunkId: batch[embeddingIndex].id,
                    studySpaceId: file.spaceId,
                    fileId: file.id,
                    model: embeddingModel,
                    vector: embedding.embedding,
                })),
            });

            embeddingsCreated += embeddings.data.length;
        }

        return {
            chunksCreated: storedChunks.length,
            embeddingsCreated,
            skipped: false,
        };
    }

    private getOpenAiClient() {
        const apiKey = this.configService.get<string>('OPENAI_API_KEY');

        if (!apiKey) {
            throw new InternalServerErrorException('OPENAI_API_KEY is not configured');
        }

        this.openai ??= new OpenAI({ apiKey });

        return this.openai;
    }

    private async extractText(file: FileForEmbedding, buffer: Buffer) {
        if (file.mimeType === 'application/pdf' || file.name.toLowerCase().endsWith('.pdf')) {
            const parser = new PDFParse({ data: buffer });

            try {
                const pdf = await parser.getText();
                return this.normalizeText(pdf.text);
            } finally {
                await parser.destroy();
            }
        }

        if (!this.isTextReadable(file)) {
            return '';
        }

        return this.normalizeText(buffer.toString('utf8'));
    }

    private chunkText(text: string): ChunkInput[] {
        const chunks: ChunkInput[] = [];
        let startChar = 0;
        let chunkIndex = 0;

        while (startChar < text.length) {
            const endChar = Math.min(startChar + this.chunkSize, text.length);
            const content = text.slice(startChar, endChar).trim();

            if (content) {
                chunks.push({
                    content,
                    chunkIndex,
                    startChar,
                    endChar,
                });
                chunkIndex += 1;
            }

            if (endChar === text.length) {
                break;
            }

            startChar = endChar - this.chunkOverlap;
        }

        return chunks;
    }

    private normalizeText(text: string) {
        return text
            .replace(/\r\n/g, '\n')
            .replace(/\r/g, '\n')
            .replace(/[ \t]+/g, ' ')
            .replace(/\n{3,}/g, '\n\n')
            .trim();
    }

    private isTextReadable(file: FileForEmbedding) {
        const lowerName = file.name.toLowerCase();

        return file.mimeType.startsWith('text/')
            || file.mimeType === 'application/json'
            || file.mimeType === 'application/xml'
            || lowerName.endsWith('.md')
            || lowerName.endsWith('.markdown')
            || lowerName.endsWith('.txt')
            || lowerName.endsWith('.csv')
            || lowerName.endsWith('.json')
            || lowerName.endsWith('.xml');
    }
}
