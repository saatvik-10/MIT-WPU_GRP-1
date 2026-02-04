-- CreateTable
CREATE TABLE "ArticleSummary" (
    "id" TEXT NOT NULL,
    "articleId" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "overview" TEXT[],
    "keyTakeaways" TEXT[],
    "jargons" TEXT[],
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ArticleSummary_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "ArticleSummary_articleId_idx" ON "ArticleSummary"("articleId");

-- AddForeignKey
ALTER TABLE "ArticleSummary" ADD CONSTRAINT "ArticleSummary_articleId_fkey" FOREIGN KEY ("articleId") REFERENCES "Article"("id") ON DELETE CASCADE ON UPDATE CASCADE;
