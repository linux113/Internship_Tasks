-- Initial PostgreSQL schema for SRIYAAN METALS CMS
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE "User" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "name" TEXT NOT NULL,
  "email" TEXT NOT NULL,
  "passwordHash" TEXT NOT NULL,
  "role" TEXT NOT NULL DEFAULT 'CONTENT_MANAGER',
  "active" BOOLEAN NOT NULL DEFAULT TRUE,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "User_email_key" UNIQUE ("email")
);

CREATE TABLE "Category" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "name" TEXT NOT NULL,
  "slug" TEXT NOT NULL,
  "description" TEXT NOT NULL DEFAULT '',
  "shortDesc" TEXT NOT NULL DEFAULT '',
  "image" TEXT NOT NULL DEFAULT '',
  "sortOrder" INTEGER NOT NULL DEFAULT 0,
  "published" BOOLEAN NOT NULL DEFAULT TRUE,
  "seoTitle" TEXT NOT NULL DEFAULT '',
  "seoDesc" TEXT NOT NULL DEFAULT '',
  "seoKeywords" TEXT NOT NULL DEFAULT '',
  CONSTRAINT "Category_slug_key" UNIQUE ("slug")
);

CREATE TABLE "Subcategory" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "name" TEXT NOT NULL,
  "slug" TEXT NOT NULL,
  "description" TEXT NOT NULL DEFAULT '',
  "image" TEXT NOT NULL DEFAULT '',
  "sortOrder" INTEGER NOT NULL DEFAULT 0,
  "categoryId" TEXT NOT NULL
);

CREATE TABLE "Product" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "name" TEXT NOT NULL,
  "slug" TEXT NOT NULL,
  "sku" TEXT NOT NULL,
  "shortDesc" TEXT NOT NULL DEFAULT '',
  "description" TEXT NOT NULL DEFAULT '',
  "categoryId" TEXT NOT NULL,
  "subcategoryId" TEXT,
  "material" TEXT NOT NULL DEFAULT '',
  "grade" TEXT NOT NULL DEFAULT '',
  "size" TEXT NOT NULL DEFAULT '',
  "diameter" TEXT NOT NULL DEFAULT '',
  "length" TEXT NOT NULL DEFAULT '',
  "standard" TEXT NOT NULL DEFAULT '',
  "finish" TEXT NOT NULL DEFAULT '',
  "threadType" TEXT NOT NULL DEFAULT '',
  "headType" TEXT NOT NULL DEFAULT '',
  "application" TEXT NOT NULL DEFAULT '',
  "availability" TEXT NOT NULL DEFAULT 'In Stock',
  "features" TEXT NOT NULL DEFAULT '',
  "featured" BOOLEAN NOT NULL DEFAULT FALSE,
  "published" BOOLEAN NOT NULL DEFAULT TRUE,
  "seoTitle" TEXT NOT NULL DEFAULT '',
  "seoDesc" TEXT NOT NULL DEFAULT '',
  "seoKeywords" TEXT NOT NULL DEFAULT '',
  "canonicalUrl" TEXT NOT NULL DEFAULT '',
  "views" INTEGER NOT NULL DEFAULT 0,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "Product_slug_key" UNIQUE ("slug"),
  CONSTRAINT "Product_sku_key" UNIQUE ("sku")
);

CREATE TABLE "ProductImage" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "url" TEXT NOT NULL,
  "alt" TEXT NOT NULL DEFAULT '',
  "sortOrder" INTEGER NOT NULL DEFAULT 0,
  "productId" TEXT NOT NULL
);

CREATE TABLE "ProductDocument" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "name" TEXT NOT NULL,
  "url" TEXT NOT NULL,
  "type" TEXT NOT NULL DEFAULT 'datasheet',
  "productId" TEXT NOT NULL
);

CREATE TABLE "ProductSpecification" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "label" TEXT NOT NULL,
  "value" TEXT NOT NULL,
  "sortOrder" INTEGER NOT NULL DEFAULT 0,
  "productId" TEXT NOT NULL
);

CREATE TABLE "Enquiry" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "type" TEXT NOT NULL DEFAULT 'product',
  "name" TEXT NOT NULL,
  "company" TEXT NOT NULL DEFAULT '',
  "email" TEXT NOT NULL,
  "phone" TEXT NOT NULL DEFAULT '',
  "country" TEXT NOT NULL DEFAULT '',
  "subject" TEXT NOT NULL DEFAULT '',
  "productId" TEXT,
  "productName" TEXT NOT NULL DEFAULT '',
  "quantity" TEXT NOT NULL DEFAULT '',
  "spec" TEXT NOT NULL DEFAULT '',
  "message" TEXT NOT NULL DEFAULT '',
  "fileUrl" TEXT NOT NULL DEFAULT '',
  "status" TEXT NOT NULL DEFAULT 'New',
  "notes" TEXT NOT NULL DEFAULT '',
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL
);

CREATE TABLE "Vendor" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "companyName" TEXT NOT NULL,
  "contactPerson" TEXT NOT NULL,
  "email" TEXT NOT NULL,
  "phone" TEXT NOT NULL DEFAULT '',
  "country" TEXT NOT NULL DEFAULT '',
  "website" TEXT NOT NULL DEFAULT '',
  "categories" TEXT NOT NULL DEFAULT '',
  "capability" TEXT NOT NULL DEFAULT '',
  "certifications" TEXT NOT NULL DEFAULT '',
  "capacity" TEXT NOT NULL DEFAULT '',
  "message" TEXT NOT NULL DEFAULT '',
  "profileUrl" TEXT NOT NULL DEFAULT '',
  "status" TEXT NOT NULL DEFAULT 'New',
  "notes" TEXT NOT NULL DEFAULT '',
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL
);

CREATE TABLE "BlogCategory" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "name" TEXT NOT NULL,
  "slug" TEXT NOT NULL,
  CONSTRAINT "BlogCategory_slug_key" UNIQUE ("slug")
);

CREATE TABLE "BlogAuthor" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "name" TEXT NOT NULL,
  "title" TEXT NOT NULL DEFAULT '',
  "bio" TEXT NOT NULL DEFAULT '',
  "image" TEXT NOT NULL DEFAULT ''
);

CREATE TABLE "Blog" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "title" TEXT NOT NULL,
  "slug" TEXT NOT NULL,
  "excerpt" TEXT NOT NULL DEFAULT '',
  "content" TEXT NOT NULL DEFAULT '',
  "image" TEXT NOT NULL DEFAULT '',
  "categoryId" TEXT NOT NULL,
  "authorId" TEXT NOT NULL,
  "featured" BOOLEAN NOT NULL DEFAULT FALSE,
  "published" BOOLEAN NOT NULL DEFAULT TRUE,
  "publishedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "seoTitle" TEXT NOT NULL DEFAULT '',
  "seoDesc" TEXT NOT NULL DEFAULT '',
  "seoKeywords" TEXT NOT NULL DEFAULT '',
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "Blog_slug_key" UNIQUE ("slug")
);

CREATE TABLE "Customer" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "name" TEXT NOT NULL,
  "logo" TEXT NOT NULL DEFAULT '',
  "website" TEXT NOT NULL DEFAULT '',
  "testimonial" TEXT NOT NULL DEFAULT '',
  "sortOrder" INTEGER NOT NULL DEFAULT 0,
  "published" BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE "Testimonial" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "quote" TEXT NOT NULL,
  "name" TEXT NOT NULL,
  "company" TEXT NOT NULL DEFAULT '',
  "designation" TEXT NOT NULL DEFAULT '',
  "photo" TEXT NOT NULL DEFAULT '',
  "sortOrder" INTEGER NOT NULL DEFAULT 0,
  "published" BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE "Certification" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "name" TEXT NOT NULL,
  "issuer" TEXT NOT NULL DEFAULT '',
  "certificateNumber" TEXT NOT NULL DEFAULT '',
  "issueDate" TIMESTAMP(3),
  "expiryDate" TIMESTAMP(3),
  "description" TEXT NOT NULL DEFAULT '',
  "image" TEXT NOT NULL DEFAULT '',
  "fileUrl" TEXT NOT NULL DEFAULT '',
  "sortOrder" INTEGER NOT NULL DEFAULT 0,
  "published" BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE "Industry" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "name" TEXT NOT NULL,
  "slug" TEXT NOT NULL,
  "description" TEXT NOT NULL DEFAULT '',
  "applications" TEXT NOT NULL DEFAULT '',
  "image" TEXT NOT NULL DEFAULT '',
  "sortOrder" INTEGER NOT NULL DEFAULT 0,
  "published" BOOLEAN NOT NULL DEFAULT TRUE,
  "seoTitle" TEXT NOT NULL DEFAULT '',
  "seoDesc" TEXT NOT NULL DEFAULT '',
  CONSTRAINT "Industry_slug_key" UNIQUE ("slug")
);

CREATE TABLE "Country" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "name" TEXT NOT NULL,
  "region" TEXT NOT NULL DEFAULT '',
  "flag" TEXT NOT NULL DEFAULT '',
  "description" TEXT NOT NULL DEFAULT '',
  "lat" DOUBLE PRECISION NOT NULL DEFAULT 0,
  "lng" DOUBLE PRECISION NOT NULL DEFAULT 0,
  "published" BOOLEAN NOT NULL DEFAULT TRUE,
  "sortOrder" INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE "WhyChoose" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "title" TEXT NOT NULL,
  "description" TEXT NOT NULL,
  "icon" TEXT NOT NULL DEFAULT 'shield',
  "sortOrder" INTEGER NOT NULL DEFAULT 0,
  "published" BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE "InfrastructureImage" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "title" TEXT NOT NULL,
  "category" TEXT NOT NULL DEFAULT 'Facility',
  "caption" TEXT NOT NULL DEFAULT '',
  "image" TEXT NOT NULL,
  "sortOrder" INTEGER NOT NULL DEFAULT 0,
  "published" BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE "Homepage" (
  "id" TEXT NOT NULL PRIMARY KEY DEFAULT 'homepage',
  "heroTitle" TEXT NOT NULL DEFAULT '',
  "heroSubtitle" TEXT NOT NULL DEFAULT '',
  "heroBg" TEXT NOT NULL DEFAULT '',
  "heroFg" TEXT NOT NULL DEFAULT '',
  "heroCtaText" TEXT NOT NULL DEFAULT 'Get a Quote',
  "heroCtaUrl" TEXT NOT NULL DEFAULT '/quote',
  "heroSecondaryText" TEXT NOT NULL DEFAULT 'Send Enquiry',
  "heroSecondaryUrl" TEXT NOT NULL DEFAULT '/contact',
  "aboutTitle" TEXT NOT NULL DEFAULT '',
  "aboutBody" TEXT NOT NULL DEFAULT '',
  "aboutImage" TEXT NOT NULL DEFAULT '',
  "aboutCta" TEXT NOT NULL DEFAULT 'Know More About Us',
  "aboutCtaUrl" TEXT NOT NULL DEFAULT '/about',
  "ctaTitle" TEXT NOT NULL DEFAULT '',
  "ctaBody" TEXT NOT NULL DEFAULT '',
  "ctaButton" TEXT NOT NULL DEFAULT 'Get a Quote',
  "ctaUrl" TEXT NOT NULL DEFAULT '/quote',
  "importBody" TEXT NOT NULL DEFAULT '',
  "exportBody" TEXT NOT NULL DEFAULT ''
);

CREATE TABLE "PageContent" (
  "slug" TEXT NOT NULL PRIMARY KEY,
  "title" TEXT NOT NULL,
  "subtitle" TEXT NOT NULL DEFAULT '',
  "body" TEXT NOT NULL DEFAULT '',
  "image" TEXT NOT NULL DEFAULT '',
  "seoTitle" TEXT NOT NULL DEFAULT '',
  "seoDesc" TEXT NOT NULL DEFAULT '',
  "seoKeywords" TEXT NOT NULL DEFAULT ''
);

CREATE TABLE "Setting" (
  "key" TEXT NOT NULL PRIMARY KEY,
  "value" TEXT NOT NULL DEFAULT ''
);

CREATE TABLE "MediaAsset" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "filename" TEXT NOT NULL,
  "storageKey" TEXT NOT NULL DEFAULT '',
  "url" TEXT NOT NULL,
  "mime" TEXT NOT NULL DEFAULT '',
  "size" INTEGER NOT NULL DEFAULT 0,
  "alt" TEXT NOT NULL DEFAULT '',
  "kind" TEXT NOT NULL DEFAULT 'image',
  "createdAt" TIMESTAMP(3) NOT NULL
);

CREATE TABLE "PageView" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "path" TEXT NOT NULL,
  "createdAt" TIMESTAMP(3) NOT NULL
);

CREATE TABLE "WebsiteContent" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "section" TEXT NOT NULL,
  "key" TEXT NOT NULL,
  "value" TEXT NOT NULL DEFAULT '',
  "updatedAt" TIMESTAMP(3) NOT NULL
);

CREATE TABLE "SocialLink" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "platform" TEXT NOT NULL,
  "url" TEXT NOT NULL,
  "published" BOOLEAN NOT NULL DEFAULT TRUE,
  "sortOrder" INTEGER NOT NULL DEFAULT 0,
  CONSTRAINT "SocialLink_platform_key" UNIQUE ("platform")
);

CREATE TABLE "ContactMessage" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "name" TEXT NOT NULL,
  "company" TEXT NOT NULL DEFAULT '',
  "email" TEXT NOT NULL,
  "phone" TEXT NOT NULL DEFAULT '',
  "country" TEXT NOT NULL DEFAULT '',
  "subject" TEXT NOT NULL DEFAULT '',
  "message" TEXT NOT NULL,
  "status" TEXT NOT NULL DEFAULT 'NEW',
  "notes" TEXT NOT NULL DEFAULT '',
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL
);

ALTER TABLE "Subcategory" ADD CONSTRAINT "Subcategory_categoryId_fkey" FOREIGN KEY ("categoryId") REFERENCES "Category"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "Product" ADD CONSTRAINT "Product_categoryId_fkey" FOREIGN KEY ("categoryId") REFERENCES "Category"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "Product" ADD CONSTRAINT "Product_subcategoryId_fkey" FOREIGN KEY ("subcategoryId") REFERENCES "Subcategory"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "ProductImage" ADD CONSTRAINT "ProductImage_productId_fkey" FOREIGN KEY ("productId") REFERENCES "Product"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "ProductDocument" ADD CONSTRAINT "ProductDocument_productId_fkey" FOREIGN KEY ("productId") REFERENCES "Product"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "ProductSpecification" ADD CONSTRAINT "ProductSpecification_productId_fkey" FOREIGN KEY ("productId") REFERENCES "Product"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "Enquiry" ADD CONSTRAINT "Enquiry_productId_fkey" FOREIGN KEY ("productId") REFERENCES "Product"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "Blog" ADD CONSTRAINT "Blog_categoryId_fkey" FOREIGN KEY ("categoryId") REFERENCES "BlogCategory"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "Blog" ADD CONSTRAINT "Blog_authorId_fkey" FOREIGN KEY ("authorId") REFERENCES "BlogAuthor"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
CREATE UNIQUE INDEX "Subcategory_categoryId_slug_key" ON "Subcategory" ("categoryId", "slug");
CREATE INDEX "Product_categoryId_idx" ON "Product" ("categoryId");
CREATE INDEX "Product_featured_published_idx" ON "Product" ("featured", "published");
CREATE INDEX "Product_sku_idx" ON "Product" ("sku");
CREATE INDEX "Product_material_idx" ON "Product" ("material");
CREATE INDEX "Product_grade_idx" ON "Product" ("grade");
CREATE INDEX "ProductSpecification_productId_sortOrder_idx" ON "ProductSpecification" ("productId", "sortOrder");
CREATE INDEX "Enquiry_status_idx" ON "Enquiry" ("status");
CREATE INDEX "Enquiry_createdAt_idx" ON "Enquiry" ("createdAt");
CREATE INDEX "Blog_published_publishedAt_idx" ON "Blog" ("published", "publishedAt");
CREATE INDEX "PageView_path_idx" ON "PageView" ("path");
CREATE INDEX "PageView_createdAt_idx" ON "PageView" ("createdAt");
CREATE UNIQUE INDEX "WebsiteContent_section_key_key" ON "WebsiteContent" ("section", "key");
CREATE INDEX "WebsiteContent_section_idx" ON "WebsiteContent" ("section");
CREATE INDEX "ContactMessage_status_createdAt_idx" ON "ContactMessage" ("status", "createdAt");
