/*
  Warnings:

  - A unique constraint covering the columns `[status]` on the table `parkour` will be added. If there are existing duplicate values, this will fail.

*/
-- CreateIndex
CREATE UNIQUE INDEX "parkour_status_key" ON "parkour"("status");
