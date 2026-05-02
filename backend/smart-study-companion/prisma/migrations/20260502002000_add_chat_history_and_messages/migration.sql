CREATE TABLE "chat_history" (
    "id" TEXT NOT NULL,
    "studySpaceId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "title" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "chat_history_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "message" (
    "id" TEXT NOT NULL,
    "chatHistoryId" TEXT NOT NULL,
    "role" TEXT NOT NULL,
    "content" TEXT NOT NULL,
    "metadata" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "message_pkey" PRIMARY KEY ("id")
);

CREATE INDEX "chat_history_studySpaceId_idx" ON "chat_history"("studySpaceId");
CREATE INDEX "chat_history_userId_idx" ON "chat_history"("userId");
CREATE INDEX "message_chatHistoryId_idx" ON "message"("chatHistoryId");

ALTER TABLE "chat_history" ADD CONSTRAINT "chat_history_studySpaceId_fkey" FOREIGN KEY ("studySpaceId") REFERENCES "study_space"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "chat_history" ADD CONSTRAINT "chat_history_userId_fkey" FOREIGN KEY ("userId") REFERENCES "user"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "message" ADD CONSTRAINT "message_chatHistoryId_fkey" FOREIGN KEY ("chatHistoryId") REFERENCES "chat_history"("id") ON DELETE CASCADE ON UPDATE CASCADE;
