-- CreateTable
CREATE TABLE "study_workspace" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "iconName" TEXT NOT NULL,
    "category" TEXT NOT NULL,
    "status" TEXT NOT NULL,
    "workspaceColorHex" TEXT NOT NULL,
    "documentCount" INTEGER NOT NULL DEFAULT 0,
    "noteCount" INTEGER NOT NULL DEFAULT 0,
    "aiOutputCount" INTEGER NOT NULL DEFAULT 0,
    "progress" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "study_workspace_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "study_workspace_userId_idx" ON "study_workspace"("userId");

-- AddForeignKey
ALTER TABLE "study_workspace" ADD CONSTRAINT "study_workspace_userId_fkey" FOREIGN KEY ("userId") REFERENCES "user"("id") ON DELETE CASCADE ON UPDATE CASCADE;
