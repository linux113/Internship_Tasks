import type { MetadataRoute } from "next";
import { prisma } from "@/lib/prisma";
import { siteUrl } from "@/lib/utils";

export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  let categories: any[] = [];
  let products: any[] = [];
  let posts: any[] = [];
  let industries: any[] = [];

  try {
    [categories, products, posts, industries] = await Promise.all([
      prisma.category.findMany({ where: { published: true } }),
      prisma.product.findMany({
        where: { published: true },
        include: { category: true },
      }),
      prisma.blog.findMany({ where: { published: true } }),
      prisma.industry.findMany({ where: { published: true } }),
    ]);
  } catch {
    /* empty sitemap is fine */
  }

  const staticPaths = [
    "",
    "/products",
    "/about",
    "/quality",
    "/manufacturing",
    "/industries",
    "/global-reach",
    "/import-export",
    "/customers",
    "/vendor",
    "/blog",
    "/contact",
    "/quote",
    "/privacy",
    "/terms",
  ];

  return [
    ...staticPaths.map((path) => ({
      url: siteUrl(path || "/"),
      changeFrequency: "weekly" as const,
      priority: path === "" ? 1 : 0.7,
    })),
    ...categories
      .filter((c) => c?.slug)
      .map((c) => ({
        url: siteUrl(`/products/${c.slug}`),
        changeFrequency: "weekly" as const,
        priority: 0.8,
      })),
    ...products
      .filter((p) => p?.slug && p?.category?.slug)
      .map((p) => ({
        url: 
