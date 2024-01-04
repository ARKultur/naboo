/*
  Warnings:

  - A unique constraint covering the columns `[uuid]` on the table `parkour` will be added. If there are existing duplicate values, this will fail.

*/
-- CreateIndex
CREATE UNIQUE INDEX "parkour_uuid_key" ON "parkour"("uuid");
