import { z } from "zod";

export const enquirySchema = z.object({
  name: z.string().min(2).max(120),
  company: z.string().max(160).optional().default(""),
  email: z.string().email(),
  phone: z.string().max(40).optional().default(""),
  country: z.string().max(80).optional().default(""),
  product: z.string().max(160).optional().default(""),
  productId: z.string().optional().default(""),
  quantity: z.string().max(80).optional().default(""),
  spec: z.string().max(2000).optional().default(""),
  message: z.string().min(8).max(4000),
  type: z.enum(["product", "general", "quote", "contact"]).optional(),
  website: z.string().optional().default(""),
});

export const vendorSchema = z.object({
  companyName: z.string().min(2).max(160),
  contactPerson: z.string().min(2).max(120),
  email: z.string().email(),
  phone: z.string().max(40).optional().default(""),
  country: z.string().max(80).optional().default(""),
  website: z.string().max(200).optional().default(""),
  categories: z.string().max(400).optional().default(""),
  capability: z.string().max(2000).optional().default(""),
  certifications: z.string().max(800).optional().default(""),
  capacity: z.string().max(400).optional().default(""),
  message: z.string().min(8).max(4000),
  honeypot: z.string().optional().default(""),
});

export const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(6),
});

export const productSchema = z.object({
  name: z.string().min(2),
  slug: z.string().min(2),
  sku: z.string().min(2),
  shortDesc: z.string().optional().default(""),
  description: z.string().optional().default(""),
  categoryId: z.string().min(1),
  subcategoryId: z.string().optional().default(""),
  material: z.string().optional().default(""),
  grade: z.string().optional().default(""),
  size: z.string().optional().default(""),
  diameter: z.string().optional().default(""),
  length: z.string().optional().default(""),
  standard: z.string().optional().default(""),
  finish: z.string().optional().default(""),
  threadType: z.string().optional().default(""),
  headType: z.string().optional().default(""),
  application: z.string().optional().default(""),
  availability: z.string().optional().default("In Stock"),
  features: z.string().optional().default(""),
  featured: z.boolean().optional().default(false),
  published: z.boolean().optional().default(true),
  seoTitle: z.string().optional().default(""),
  seoDesc: z.string().optional().default(""),
  seoKeywords: z.string().optional().default(""),
  imageUrl: z.string().optional().default(""),
});
