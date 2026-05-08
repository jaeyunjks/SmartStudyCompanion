import {
    BadRequestException,
    ForbiddenException,
    Inject,
    Injectable,
    InternalServerErrorException,
    NotFoundException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import OpenAI from 'openai';
import { StudySpaceService } from '../study-space/study-space.service';
import { FileService } from '../file/file.service';
import { StorageRepository } from '../file-storage/file-storage.repository';
import { PrismaService } from '../../prisma/prisma.service';

type StudySpaceSummary = {
    overview: string;
    keyConcepts: string[];
    importantDetails: string[];
    quickTakeaways: string[];
    suggestedNextActions: string[];
};

type StudySpaceAsset = {
    id: string;
    name: string;
    mimeType: string;
    size: number;
    url: string;
};

type RankedChunk = {
    chunkId: string;
    fileId: string;
    fileName: string;
    chunkIndex: number;
    content: string;
    score: number;
};

@Injectable()
export class AiService {
    private openai?: OpenAI;
    private readonly maxTextFileChars = 12000;
    private readonly defaultChatSummaryTokenLimit = 800;
    private readonly messagesPerSummaryUpdate = 10;

    constructor(
        private readonly configService: ConfigService,
        private readonly studySpaceService: StudySpaceService,
        private readonly fileService: FileService,
        private readonly prisma: PrismaService,
        @Inject('STORAGE_REPOSITORY')
        private readonly storageRepo: StorageRepository,
    ) {
    }

    private getOpenAiClient() {
        const apiKey = this.configService.get<string>('OPENAI_API_KEY');

        if (!apiKey) {
            throw new InternalServerErrorException('OPENAI_API_KEY is not configured');
        }

        this.openai ??= new OpenAI({ apiKey });

        return this.openai;
    }

    async summarizeStudySpace(
        studySpaceId: string,
        userId: string,
        fileIds: string[],
        title?: string,
        sourceContent?: string,
    ) {
        const uniqueFileIds = [...new Set(fileIds.map((fileId) => fileId.trim()).filter(Boolean))];
        const cleanSourceContent = sourceContent?.trim() ?? '';

        if (!uniqueFileIds.length && !cleanSourceContent) {
            throw new BadRequestException('At least one fileId or sourceContent is required');
        }

        const studySpace = await this.studySpaceService.getStudySpaceById(studySpaceId);

        if (studySpace.userId !== userId) {
            throw new ForbiddenException("You don't have access to summarize this study space");
        }

        const files = uniqueFileIds.length
            ? await this.fileService.getFilesBySpaceId(studySpaceId)
            : [];
        const selectedFiles = files.filter((item: any) => uniqueFileIds.includes(item.file.id));

        if (selectedFiles.length !== uniqueFileIds.length) {
            throw new BadRequestException('One or more selected files do not belong to this study space');
        }

        const fileAssets = selectedFiles.map((item: any) => ({
            id: item.file.id,
            name: item.file.name,
            mimeType: item.file.mimeType,
            size: item.file.size,
            url: item.url,
        }));

        const fileSummaries = await Promise.all(
            fileAssets.map((file) => this.readTextFileForPrompt(file)),
        );

        const userContent: any[] = [{
            type: 'text',
            text: this.buildStudySpacePrompt(studySpace.title, fileSummaries, cleanSourceContent),
        }];

        const completion = await this.getOpenAiClient().chat.completions.create({
            model: this.configService.get<string>('GPT_MODEL') ?? 'gpt-4o-mini',
            response_format: {
                type: 'json_object',
            },
            messages: [
                {
                    role: 'system',
                    content: 'You are an expert study assistant. Summarize study materials accurately and only use the selected supplied source content. Return valid JSON with exactly these keys: overview, keyConcepts, importantDetails, quickTakeaways, suggestedNextActions. keyConcepts must be concise "Term: definition" strings. All array items must be specific, useful, and grounded in the supplied content.',
                },
                {
                    role: 'user',
                    content: userContent,
                },
            ],
        });

        const rawSummary = completion.choices[0]?.message?.content;

        if (!rawSummary) {
            throw new InternalServerErrorException("Couldn't generate study space summary");
        }

        const summary = this.parseSummary(rawSummary);
        const createdSummary = await this.prisma.studySpaceSummary.create({
            data: {
                studySpaceId,
                userId,
                title: title?.trim() || this.createSummaryTitle(fileAssets),
                content: summary,
                ...(fileAssets.length
                    ? {
                        files: {
                            create: fileAssets.map((file) => ({
                                fileId: file.id,
                            })),
                        },
                    }
                    : {}),
            },
            include: {
                files: {
                    include: {
                        file: true,
                    },
                },
            },
        });

        return {
            summary: createdSummary,
        };
    }

    async getStudySpaceSummaries(studySpaceId: string, userId: string) {
        const studySpace = await this.studySpaceService.getStudySpaceById(studySpaceId);

        if (studySpace.userId !== userId) {
            throw new ForbiddenException("You don't have access to this study space");
        }

        return this.prisma.studySpaceSummary.findMany({
            where: {
                studySpaceId,
                userId,
            },
            include: {
                files: {
                    include: {
                        file: true,
                    },
                },
            },
            orderBy: {
                createdAt: 'desc',
            },
        });
    }

    async getStudySpaceSummary(summaryId: string, userId: string) {
        const summary = await this.prisma.studySpaceSummary.findUnique({
            where: {
                id: summaryId,
            },
            include: {
                files: {
                    include: {
                        file: true,
                    },
                },
            },
        });

        if (!summary) {
            throw new NotFoundException('Summary not found', 'Summary not found');
        }

        if (summary.userId !== userId) {
            throw new ForbiddenException("You don't have access to this summary");
        }

        return summary;
    }

    async chatWithStudySpace(
        studySpaceId: string,
        userId: string,
        prompt: string,
        chatHistoryId?: string,
        title?: string,
    ) {
        const cleanPrompt = prompt?.trim();

        if (!cleanPrompt) {
            throw new BadRequestException('Prompt is required');
        }

        const studySpace = await this.studySpaceService.getStudySpaceById(studySpaceId);

        if (studySpace.userId !== userId) {
            throw new ForbiddenException("You don't have access to chat with this study space");
        }

        const chatHistory = await this.getOrCreateChatHistory(studySpaceId, userId, cleanPrompt, chatHistoryId, title);
        const { chatSummary, unsummarizedMessages } = await this.getChatContext(chatHistory.id);

        const relevantChunks = await this.findRelevantChunks(studySpaceId, cleanPrompt);
        const aiResponse = await this.generateChatResponse(studySpace.title, cleanPrompt, relevantChunks, unsummarizedMessages, chatSummary?.content);

        const [userMessage, assistantMessage] = await this.prisma.$transaction([
            this.prisma.message.create({
                data: {
                    chatHistoryId: chatHistory.id,
                    role: 'user',
                    content: cleanPrompt,
                },
            }),
            this.prisma.message.create({
                data: {
                    chatHistoryId: chatHistory.id,
                    role: 'assistant',
                    content: aiResponse,
                    metadata: {
                        sources: relevantChunks.map((chunk) => ({
                            chunkId: chunk.chunkId,
                            fileId: chunk.fileId,
                            fileName: chunk.fileName,
                            chunkIndex: chunk.chunkIndex,
                            score: chunk.score,
                        })),
                    },
                },
            }),
            this.prisma.chatHistory.update({
                where: {
                    id: chatHistory.id,
                },
                data: {
                    updatedAt: new Date(),
                },
            }),
        ]);

        await this.updateChatSummaryIfNeeded(chatHistory.id);

        return {
            chatHistoryId: chatHistory.id,
            messages: [
                userMessage,
                assistantMessage,
            ],
            sources: relevantChunks.map((chunk) => ({
                chunkId: chunk.chunkId,
                fileId: chunk.fileId,
                fileName: chunk.fileName,
                chunkIndex: chunk.chunkIndex,
                score: chunk.score,
            })),
        };
    }

    async getChatHistory(chatHistoryId: string, userId: string) {
        const chatHistory = await this.prisma.chatHistory.findUnique({
            where: {
                id: chatHistoryId,
            },
            include: {
                messages: {
                    orderBy: {
                        createdAt: 'asc',
                    },
                },
            },
        });

        if (!chatHistory) {
            throw new NotFoundException('Chat history not found', 'Chat history not found');
        }

        if (chatHistory.userId !== userId) {
            throw new ForbiddenException("You don't have access to this chat history");
        }

        return chatHistory;
    }

    async getChatHistoryMessages(
        chatHistoryId: string,
        userId: string,
        limitQuery?: string,
        beforeMessageId?: string,
    ) {
        const chatHistory = await this.prisma.chatHistory.findUnique({
            where: {
                id: chatHistoryId,
            },
        });

        if (!chatHistory) {
            throw new NotFoundException('Chat history not found', 'Chat history not found');
        }

        if (chatHistory.userId !== userId) {
            throw new ForbiddenException("You don't have access to this chat history");
        }

        const limit = this.parseMessageLimit(limitQuery);
        const beforeMessage = beforeMessageId
            ? await this.prisma.message.findUnique({
                where: {
                    id: beforeMessageId,
                },
            })
            : null;

        if (beforeMessageId && (!beforeMessage || beforeMessage.chatHistoryId !== chatHistoryId)) {
            throw new NotFoundException('Cursor message not found', 'Cursor message not found');
        }

        const messages = await this.prisma.message.findMany({
            where: {
                chatHistoryId,
                ...(beforeMessage ? {
                    createdAt: {
                        lt: beforeMessage.createdAt,
                    },
                } : {}),
            },
            orderBy: {
                createdAt: 'desc',
            },
            take: limit + 1,
        });

        const hasMore = messages.length > limit;
        const page = messages.slice(0, limit).reverse();

        return {
            chatHistoryId,
            messages: page,
            hasMore,
            nextBeforeMessageId: hasMore ? page[0]?.id : null,
        };
    }

    private async getChatContext(chatHistoryId: string) {
        const [chatSummary, messages] = await Promise.all([
            this.prisma.chatSummary.findUnique({
                where: {
                    chatHistoryId,
                },
            }),
            this.prisma.message.findMany({
                where: {
                    chatHistoryId,
                },
                orderBy: {
                    createdAt: 'asc',
                },
            }),
        ]);

        const summarizedMessageCount = chatSummary?.summarizedMessageCount ?? 0;

        return {
            chatSummary,
            unsummarizedMessages: messages.slice(summarizedMessageCount),
        };
    }

    private async updateChatSummaryIfNeeded(chatHistoryId: string) {
        const messages = await this.prisma.message.findMany({
            where: {
                chatHistoryId,
            },
            orderBy: {
                createdAt: 'asc',
            },
        });

        if (!messages.length || messages.length % this.messagesPerSummaryUpdate !== 0) {
            return;
        }

        const currentSummary = await this.prisma.chatSummary.findUnique({
            where: {
                chatHistoryId,
            },
        });

        if (currentSummary?.summarizedMessageCount === messages.length) {
            return;
        }

        const summaryTokenLimit = this.getChatSummaryTokenLimit();
        const messagesToSummarize = messages.slice(currentSummary?.summarizedMessageCount ?? 0);
        const summary = await this.generateChatSummary(currentSummary?.content, messagesToSummarize, summaryTokenLimit);

        await this.prisma.chatSummary.upsert({
            where: {
                chatHistoryId,
            },
            create: {
                chatHistoryId,
                content: summary,
                tokenLimit: summaryTokenLimit,
                summarizedMessageCount: messages.length,
            },
            update: {
                content: summary,
                tokenLimit: summaryTokenLimit,
                summarizedMessageCount: messages.length,
            },
        });
    }

    private async generateChatSummary(existingSummary: string | undefined, messages: any[], tokenLimit: number) {
        const messageText = messages
            .map((message) => `${message.role}: ${message.content}`)
            .join('\n\n');

        const completion = await this.getOpenAiClient().chat.completions.create({
            model: this.configService.get<string>('GPT_MODEL') ?? 'gpt-4o-mini',
            messages: [
                {
                    role: 'system',
                    content: [
                        'Summarize this study chat for future context.',
                        `Keep the summary under ${tokenLimit} tokens.`,
                        'Preserve user goals, important answers, unresolved questions, referenced files, and any facts needed to continue the conversation.',
                        'Do not add information that is not present in the chat.',
                    ].join(' '),
                },
                {
                    role: 'user',
                    content: [
                        existingSummary ? `Existing summary:\n${existingSummary}` : 'Existing summary: none',
                        '',
                        'New messages to merge:',
                        messageText,
                    ].join('\n'),
                },
            ],
        });

        const summary = completion.choices[0]?.message?.content;

        if (!summary) {
            throw new InternalServerErrorException("Couldn't generate chat summary");
        }

        return this.truncateToApproxTokenLimit(summary, tokenLimit);
    }

    private async readTextFileForPrompt(file: StudySpaceAsset) {
        const base = {
            name: file.name,
            mimeType: file.mimeType,
            size: file.size,
        };

        if (!this.isTextReadable(file)) {
            return {
                ...base,
                readable: false,
                content: 'Binary or unsupported document type. Use the filename and metadata only.',
            };
        }

        const content = await this.storageRepo.readText(file.url);
        const truncated = content.length > this.maxTextFileChars;

        return {
            ...base,
            readable: true,
            truncated,
            content: truncated ? content.slice(0, this.maxTextFileChars) : content,
        };
    }

    private buildStudySpacePrompt(title: string, files: any[], sourceContent: string) {
        const sourceContentBlock = sourceContent
            ? [
                'Selected source text:',
                sourceContent.slice(0, this.maxTextFileChars),
            ].join('\n')
            : '';

        return [
            `Summarize the selected study material from the study space named "${title}".`,
            'Focus on what a student should understand, remember, and review next.',
            'Use the selected source text as the primary source of truth. If file metadata is also supplied, use it only as context and never invent content from an unreadable file name.',
            'Write one useful overview paragraph.',
            'Return 4-8 key concepts as "Term: definition" strings.',
            'Return 5-8 importantDetails as concrete learning points.',
            'Return 3-5 quickTakeaways as short exam-review takeaways.',
            'Return 3-5 suggestedNextActions as practical study actions, not repeated key points.',
            '',
            sourceContentBlock,
            '',
            'Selected files:',
            JSON.stringify(files, null, 2),
        ].join('\n');
    }

    private parseSummary(rawSummary: string): StudySpaceSummary {
        try {
            const parsed = JSON.parse(rawSummary);

            return {
                overview: String(parsed.overview ?? ''),
                keyConcepts: Array.isArray(parsed.keyConcepts)
                    ? parsed.keyConcepts.map(String)
                    : [],
                importantDetails: Array.isArray(parsed.importantDetails)
                    ? parsed.importantDetails.map(String)
                    : [],
                quickTakeaways: Array.isArray(parsed.quickTakeaways)
                    ? parsed.quickTakeaways.map(String)
                    : [],
                suggestedNextActions: Array.isArray(parsed.suggestedNextActions)
                    ? parsed.suggestedNextActions.map(String)
                    : [],
            };
        } catch {
            throw new InternalServerErrorException("Couldn't parse study space summary");
        }
    }

    private isTextReadable(file: StudySpaceAsset) {
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

    private async getOrCreateChatHistory(
        studySpaceId: string,
        userId: string,
        prompt: string,
        chatHistoryId?: string,
        title?: string,
    ) {
        if (!chatHistoryId) {
            return this.prisma.chatHistory.create({
                data: {
                    studySpaceId,
                    userId,
                    title: title?.trim() || this.createChatTitle(prompt),
                },
            });
        }

        const chatHistory = await this.prisma.chatHistory.findUnique({
            where: {
                id: chatHistoryId,
            },
        });

        if (!chatHistory) {
            throw new NotFoundException('Chat history not found', 'Chat history not found');
        }

        if (chatHistory.userId !== userId || chatHistory.studySpaceId !== studySpaceId) {
            throw new ForbiddenException("You don't have access to this chat history");
        }

        return chatHistory;
    }

    private async findRelevantChunks(studySpaceId: string, prompt: string): Promise<RankedChunk[]> {
        const promptEmbedding = await this.createEmbedding(prompt);
        const chunkEmbeddings = await this.prisma.chunkEmbedding.findMany({
            where: {
                studySpaceId,
            },
            include: {
                chunk: {
                    include: {
                        file: true,
                    },
                },
            },
        });

        if (!chunkEmbeddings.length) {
            return [];
        }

        const rankedChunks = chunkEmbeddings
            .map((embedding: any) => {
                const filenameScore = this.getFilenameRelevance(prompt, embedding.chunk.file.name);

                return {
                    chunkId: embedding.chunkId,
                    fileId: embedding.fileId,
                    fileName: embedding.chunk.file.name,
                    chunkIndex: embedding.chunk.chunkIndex,
                    content: embedding.chunk.content,
                    score: this.cosineSimilarity(promptEmbedding, embedding.vector) + filenameScore,
                };
            })
            .sort((left, right) => right.score - left.score);

        return rankedChunks.slice(0, 8);
    }

    private async createEmbedding(input: string) {
        const embeddingModel = this.configService.get<string>('TEXT_EMBEDDING_MODEL') ?? 'text-embedding-3-small';
        const embedding = await this.getOpenAiClient().embeddings.create({
            model: embeddingModel,
            input,
        });

        return embedding.data[0].embedding;
    }

    private async generateChatResponse(
        studySpaceTitle: string,
        prompt: string,
        chunks: RankedChunk[],
        unsummarizedMessages: any[],
        chatSummary?: string,
    ) {
        const context = chunks.length
            ? chunks.map((chunk, index) => [
                `Source ${index + 1}`,
                `File: ${chunk.fileName}`,
                `Chunk: ${chunk.chunkIndex}`,
                `Content: ${chunk.content}`,
            ].join('\n')).join('\n\n')
            : 'No relevant uploaded-file chunks were found.';

        const messages: any[] = [
            {
                role: 'system',
                content: [
                    'You are a study assistant answering questions about uploaded study-space files.',
                    'Use the provided retrieved chunks as the primary source of truth.',
                    'If the chunks do not contain enough information, say what is missing instead of inventing details.',
                    'Use the chat summary and recent messages only as conversation context, not as a replacement for uploaded-file evidence.',
                    'When useful, mention the file names that support the answer.',
                ].join(' '),
            },
            ...(chatSummary ? [{
                role: 'system',
                content: `Summary of earlier chat messages:\n${chatSummary}`,
            }] : []),
            ...unsummarizedMessages.map((message) => ({
                role: message.role,
                content: message.content,
            })),
            {
                role: 'user',
                content: [
                    `Study space: ${studySpaceTitle}`,
                    '',
                    'Relevant uploaded-file chunks:',
                    context,
                    '',
                    `User question: ${prompt}`,
                ].join('\n'),
            },
        ];

        const completion = await this.getOpenAiClient().chat.completions.create({
            model: this.configService.get<string>('GPT_MODEL') ?? 'gpt-4o-mini',
            messages,
        });

        const response = completion.choices[0]?.message?.content;

        if (!response) {
            throw new InternalServerErrorException("Couldn't generate chat response");
        }

        return response;
    }

    private cosineSimilarity(left: number[], right: number[]) {
        let dotProduct = 0;
        let leftMagnitude = 0;
        let rightMagnitude = 0;
        const length = Math.min(left.length, right.length);

        for (let index = 0; index < length; index += 1) {
            dotProduct += left[index] * right[index];
            leftMagnitude += left[index] * left[index];
            rightMagnitude += right[index] * right[index];
        }

        if (!leftMagnitude || !rightMagnitude) {
            return 0;
        }

        return dotProduct / (Math.sqrt(leftMagnitude) * Math.sqrt(rightMagnitude));
    }

    private getFilenameRelevance(prompt: string, fileName: string) {
        const promptTokens = this.tokenize(prompt);
        const fileTokens = this.tokenize(fileName);

        if (!promptTokens.length || !fileTokens.length) {
            return 0;
        }

        const normalizedPrompt = prompt.toLowerCase();
        const normalizedFileName = fileName.toLowerCase();

        if (normalizedPrompt.includes(normalizedFileName)) {
            return 0.3;
        }

        const matchedTokens = fileTokens.filter((token) => promptTokens.includes(token));

        return Math.min(matchedTokens.length * 0.08, 0.24);
    }

    private tokenize(value: string) {
        return value
            .toLowerCase()
            .split(/[^a-z0-9]+/)
            .filter((token) => token.length >= 3);
    }

    private createChatTitle(prompt: string) {
        return prompt.length > 60 ? `${prompt.slice(0, 57)}...` : prompt;
    }

    private createSummaryTitle(files: StudySpaceAsset[]) {
        if (!files.length) {
            return 'Selected source summary';
        }

        if (files.length === 1) {
            return files[0].name;
        }

        return `${files[0].name} and ${files.length - 1} more`;
    }

    private getChatSummaryTokenLimit() {
        const configuredLimit = Number(this.configService.get<string>('CHAT_SUMMARY_TOKEN_LIMIT'));

        if (Number.isFinite(configuredLimit) && configuredLimit > 0) {
            return configuredLimit;
        }

        return this.defaultChatSummaryTokenLimit;
    }

    private truncateToApproxTokenLimit(value: string, tokenLimit: number) {
        const maxCharacters = tokenLimit * 4;

        if (value.length <= maxCharacters) {
            return value;
        }

        return value.slice(0, maxCharacters).trim();
    }

    private parseMessageLimit(limitQuery?: string) {
        const parsedLimit = Number(limitQuery);

        if (!Number.isFinite(parsedLimit) || parsedLimit <= 0) {
            return 10;
        }

        return Math.min(Math.floor(parsedLimit), 50);
    }
}
