CREATE TABLE "study_space_summary" (
    "id" TEXT NOT NULL,
    "studySpaceId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "title" TEXT,
    "content" JSONB NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "study_space_summary_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "study_space_summary_file" (
    "id" TEXT NOT NULL,
    "summaryId" TEXT NOT NULL,
    "fileId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "study_space_summary_file_pkey" PRIMARY KEY ("id")
);

INSERT INTO "study_space_summary" ("id", "studySpaceId", "userId", "title", "content", "createdAt", "updatedAt")
SELECT
    'legacy-' || "id",
    "id",
    "userId",
    'Study space summary',
    "summary",
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM "study_space"
WHERE "summary" IS NOT NULL;

INSERT INTO "study_space_summary_file" ("id", "summaryId", "fileId", "createdAt")
SELECT
    'legacy-' || summary."id" || '-' || file."id",
    summary."id",
    file."id",
    CURRENT_TIMESTAMP
FROM "study_space_summary" summary
INNER JOIN "file" file ON file."spaceId" = summary."studySpaceId"
WHERE summary."id" LIKE 'legacy-%';

CREATE INDEX "study_space_summary_studySpaceId_idx" ON "study_space_summary"("studySpaceId");
CREATE INDEX "study_space_summary_userId_idx" ON "study_space_summary"("userId");
CREATE INDEX "study_space_summary_file_summaryId_idx" ON "study_space_summary_file"("summaryId");
CREATE INDEX "study_space_summary_file_fileId_idx" ON "study_space_summary_file"("fileId");
CREATE UNIQUE INDEX "study_space_summary_file_summaryId_fileId_key" ON "study_space_summary_file"("summaryId", "fileId");

ALTER TABLE "study_space_summary" ADD CONSTRAINT "study_space_summary_studySpaceId_fkey" FOREIGN KEY ("studySpaceId") REFERENCES "study_space"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "study_space_summary" ADD CONSTRAINT "study_space_summary_userId_fkey" FOREIGN KEY ("userId") REFERENCES "user"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "study_space_summary_file" ADD CONSTRAINT "study_space_summary_file_summaryId_fkey" FOREIGN KEY ("summaryId") REFERENCES "study_space_summary"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "study_space_summary_file" ADD CONSTRAINT "study_space_summary_file_fileId_fkey" FOREIGN KEY ("fileId") REFERENCES "file"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "study_space" DROP COLUMN "summary";
