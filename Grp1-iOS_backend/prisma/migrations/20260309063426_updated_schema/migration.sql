/*
  Warnings:

  - You are about to drop the column `averageAccuracy` on the `UserProgress` table. All the data in the column will be lost.
  - You are about to drop the column `quizLevel` on the `UserProgress` table. All the data in the column will be lost.
  - You are about to drop the column `totalQuizzesPlayed` on the `UserProgress` table. All the data in the column will be lost.
  - You are about to drop the `ChatMessage` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `ChatSession` table. If the table is not empty, all the data it contains will be lost.

*/
-- DropForeignKey
ALTER TABLE "ChatMessage" DROP CONSTRAINT "ChatMessage_sessionId_fkey";

-- DropForeignKey
ALTER TABLE "ChatSession" DROP CONSTRAINT "ChatSession_userId_fkey";

-- AlterTable
ALTER TABLE "UserProgress" DROP COLUMN "averageAccuracy",
DROP COLUMN "quizLevel",
DROP COLUMN "totalQuizzesPlayed";

-- DropTable
DROP TABLE "ChatMessage";

-- DropTable
DROP TABLE "ChatSession";
