CREATE TABLE "chunk" (
    "id" TEXT NOT NULL,
    "studySpaceId" TEXT NOT NULL,
    "fileId" TEXT NOT NULL,
    "content" TEXT NOT NULL,
    "chunkIndex" INTEGER NOT NULL,
    "startChar" INTEGER NOT NULL,
    "endChar" INTEGER NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "chunk_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "chunk_embedding" (
    "id" TEXT NOT NULL,
    "chunkId" TEXT NOT NULL,
    "studySpaceId" TEXT NOT NULL,
    "fileId" TEXT NOT NULL,
    "model" TEXT NOT NULL,
    "vector" DOUBLE PRECISION[] NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "chunk_embedding_pkey" PRIMARY KEY ("id")
);

CREATE INDEX "chunk_studySpaceId_idx" ON "chunk"("studySpaceId");
CREATE INDEX "chunk_fileId_idx" ON "chunk"("fileId");
CREATE UNIQUE INDEX "chunk_fileId_chunkIndex_key" ON "chunk"("fileId", "chunkIndex");

CREATE UNIQUE INDEX "chunk_embedding_chunkId_key" ON "chunk_embedding"("chunkId");
CREATE INDEX "chunk_embedding_studySpaceId_idx" ON "chunk_embedding"("studySpaceId");
CREATE INDEX "chunk_embedding_fileId_idx" ON "chunk_embedding"("fileId");

ALTER TABLE "chunk" ADD CONSTRAINT "chunk_studySpaceId_fkey" FOREIGN KEY ("studySpaceId") REFERENCES "study_space"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "chunk" ADD CONSTRAINT "chunk_fileId_fkey" FOREIGN KEY ("fileId") REFERENCES "file"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "chunk_embedding" ADD CONSTRAINT "chunk_embedding_chunkId_fkey" FOREIGN KEY ("chunkId") REFERENCES "chunk"("id") ON DELETE CASCADE ON UPDATE CASCADE;
