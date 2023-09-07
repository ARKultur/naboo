/*
  Warnings:

  - You are about to drop the column `text` on the `guide` table. All the data in the column will be lost.
  - Added the required column `description` to the `guide` table without a default value. This is not possible if the table is not empty.
  - Added the required column `title` to the `guide` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "guide" DROP COLUMN "text",
ADD COLUMN     "description" VARCHAR(255) NOT NULL,
ADD COLUMN     "keywords" TEXT[],
ADD COLUMN     "openingHours" TEXT[],
ADD COLUMN     "priceDesc" TEXT[],
ADD COLUMN     "priceValue" DOUBLE PRECISION[],
ADD COLUMN     "title" TEXT NOT NULL,
ADD COLUMN     "website" TEXT;

-- CreateTable
CREATE TABLE "review" (
    "id" TEXT NOT NULL,
    "stars" INTEGER NOT NULL,
    "message" TEXT NOT NULL,
    "guideId" INTEGER NOT NULL,
    "userId" INTEGER NOT NULL,
    "datetime" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "review_pkey" PRIMARY KEY ("id")
);

-- AddForeignKey
ALTER TABLE "review" ADD CONSTRAINT "review_guideId_fkey" FOREIGN KEY ("guideId") REFERENCES "guide"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "review" ADD CONSTRAINT "review_userId_fkey" FOREIGN KEY ("userId") REFERENCES "user"("id") ON DELETE CASCADE ON UPDATE CASCADE;
