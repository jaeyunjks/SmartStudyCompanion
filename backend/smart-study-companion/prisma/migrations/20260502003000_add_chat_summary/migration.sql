CREATE TABLE "chat_summary" (
    "id" TEXT NOT NULL,
    "chatHistoryId" TEXT NOT NULL,
    "content" TEXT NOT NULL,
    "tokenLimit" INTEGER NOT NULL,
    "summarizedMessageCount" INTEGER NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "chat_summary_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "chat_summary_chatHistoryId_key" ON "chat_summary"("chatHistoryId");

ALTER TABLE "chat_summary" ADD CONSTRAINT "chat_summary_chatHistoryId_fkey" FOREIGN KEY ("chatHistoryId") REFERENCES "chat_history"("id") ON DELETE CASCADE ON UPDATE CASCADE;
