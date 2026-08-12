import type { MetadataRoute } from "next";
import { prisma } from "@/lib/prisma";
import { siteUrl } from "@/lib/utils";

export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  const [categories, products, posts, industries] = await Promise.all([
    prisma.category.findMany({ where: { published: true }, select: { slug: true } }),
    prisma.product.findMany({
      where: { published: true },
      select: { slug: true, category: { select: { slug: true } }, updatedAt: true },
    }),
    prisma.blog.findMany({
      where: { published: true },
      select: { slug: true, updatedAt: true },
    }),
    prisma.industry.findMany({
      where: { published: true },
      select: { slug: true },
    }),
  ]);

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
    ...categories.map((c) => ({
      url: siteUrl(`/products/${c.slug}`),
      changeFrequency: "weekly" as const,
      priority: 0.8,
    })),
    ...products.map((p) => ({
      url: siteUrl(`/products/${p.category.slug}/${p.slug}`),
      lastModified: p.updatedAt,
      changeFrequency: "weekly" as const,
      priority: 0.8,
    })),
    ...posts.map((p) => ({
      url: siteUrl(`/blog/${p.slug}`),
      lastModified: p.updatedAt,
      changeFrequency: "monthly" as const,
      priority: 0.6,
    })),
    ...industries.map((i) => ({
      url: siteUrl(`/industries/${i.slug}`),
      changeFrequency: "monthly" as const,
      priority: 0.6,
    })),
  ];
}
