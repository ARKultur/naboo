-- CreateTable
CREATE TABLE "newsletter" (
    "uuid" TEXT NOT NULL,
    "email" VARCHAR(255) NOT NULL,

    CONSTRAINT "newsletter_pkey" PRIMARY KEY ("uuid")
);

-- CreateTable
CREATE TABLE "suggestions" (
    "uuid" TEXT NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "description" VARCHAR(255) NOT NULL,
    "imageUrl" VARCHAR(255) NOT NULL,
    "userId" INTEGER,

    CONSTRAINT "suggestions_pkey" PRIMARY KEY ("uuid")
);

-- CreateIndex
CREATE UNIQUE INDEX "newsletter_email_key" ON "newsletter"("email");

-- CreateIndex
CREATE UNIQUE INDEX "suggestions_name_key" ON "suggestions"("name");

-- CreateIndex
CREATE UNIQUE INDEX "suggestions_description_key" ON "suggestions"("description");

-- CreateIndex
CREATE UNIQUE INDEX "suggestions_imageUrl_key" ON "suggestions"("imageUrl");

-- AddForeignKey
ALTER TABLE "suggestions" ADD CONSTRAINT "suggestions_userId_fkey" FOREIGN KEY ("userId") REFERENCES "user"("id") ON DELETE SET NULL ON UPDATE CASCADE;
