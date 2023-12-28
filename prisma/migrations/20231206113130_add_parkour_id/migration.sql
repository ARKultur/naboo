-- CreateTable
CREATE TABLE "_nodesToparkour" (
    "A" INTEGER NOT NULL,
    "B" TEXT NOT NULL
);

-- CreateIndex
CREATE UNIQUE INDEX "_nodesToparkour_AB_unique" ON "_nodesToparkour"("A", "B");

-- CreateIndex
CREATE INDEX "_nodesToparkour_B_index" ON "_nodesToparkour"("B");

-- AddForeignKey
ALTER TABLE "_nodesToparkour" ADD CONSTRAINT "_nodesToparkour_A_fkey" FOREIGN KEY ("A") REFERENCES "nodes"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "_nodesToparkour" ADD CONSTRAINT "_nodesToparkour_B_fkey" FOREIGN KEY ("B") REFERENCES "parkour"("uuid") ON DELETE CASCADE ON UPDATE CASCADE;
