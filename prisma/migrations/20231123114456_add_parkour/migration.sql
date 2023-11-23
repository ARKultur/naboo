-- CreateTable
CREATE TABLE "parkour" (
    "name" VARCHAR(255) NOT NULL,
    "description" VARCHAR(255) NOT NULL,
    "uuid" TEXT NOT NULL,
    "createdAt" TIMESTAMPTZ(2) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(2) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "status" TEXT NOT NULL,
    "OrganisationId" INTEGER,

    CONSTRAINT "parkour_pkey" PRIMARY KEY ("uuid")
);

-- CreateIndex
CREATE UNIQUE INDEX "parkour_name_key" ON "parkour"("name");

-- CreateIndex
CREATE UNIQUE INDEX "parkour_description_key" ON "parkour"("description");

-- AddForeignKey
ALTER TABLE "parkour" ADD CONSTRAINT "parkour_OrganisationId_fkey" FOREIGN KEY ("OrganisationId") REFERENCES "organisations"("id") ON DELETE CASCADE ON UPDATE CASCADE;
