-- CreateTable
CREATE TABLE "study_space" (
    "id" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "study_space_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "note" (
    "id" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "spaceId" TEXT NOT NULL,
    "content" JSONB NOT NULL DEFAULT '{}',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "note_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "file" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "mimeType" TEXT NOT NULL,
    "size" INTEGER NOT NULL,
    "userId" TEXT NOT NULL,
    "spaceId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "file_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "image" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "mimeType" TEXT NOT NULL,
    "size" INTEGER NOT NULL,
    "userId" TEXT NOT NULL,
    "spaceId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "image_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "study_space_userId_idx" ON "study_space"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "study_space_title_userId_key" ON "study_space"("title", "userId");

-- CreateIndex
CREATE INDEX "note_spaceId_idx" ON "note"("spaceId");

-- CreateIndex
CREATE UNIQUE INDEX "note_title_spaceId_key" ON "note"("title", "spaceId");

-- CreateIndex
CREATE INDEX "file_spaceId_idx" ON "file"("spaceId");

-- CreateIndex
CREATE UNIQUE INDEX "file_name_spaceId_key" ON "file"("name", "spaceId");

-- CreateIndex
CREATE INDEX "image_spaceId_idx" ON "image"("spaceId");

-- CreateIndex
CREATE UNIQUE INDEX "image_name_spaceId_key" ON "image"("name", "spaceId");

-- AddForeignKey
ALTER TABLE "study_space" ADD CONSTRAINT "study_space_userId_fkey" FOREIGN KEY ("userId") REFERENCES "user"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "note" ADD CONSTRAINT "note_spaceId_fkey" FOREIGN KEY ("spaceId") REFERENCES "study_space"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "file" ADD CONSTRAINT "file_userId_fkey" FOREIGN KEY ("userId") REFERENCES "user"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "file" ADD CONSTRAINT "file_spaceId_fkey" FOREIGN KEY ("spaceId") REFERENCES "study_space"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "image" ADD CONSTRAINT "image_userId_fkey" FOREIGN KEY ("userId") REFERENCES "user"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "image" ADD CONSTRAINT "image_spaceId_fkey" FOREIGN KEY ("spaceId") REFERENCES "study_space"("id") ON DELETE CASCADE ON UPDATE CASCADE;
