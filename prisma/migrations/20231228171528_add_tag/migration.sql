/*
  Warnings:

  - A unique constraint covering the columns `[tag]` on the table `suggestions` will be added. If there are existing duplicate values, this will fail.
  - Added the required column `tag` to the `suggestions` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "suggestions" ADD COLUMN     "tag" VARCHAR(255) NOT NULL;

-- CreateIndex
CREATE UNIQUE INDEX "suggestions_tag_key" ON "suggestions"("tag");
