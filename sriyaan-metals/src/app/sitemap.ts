import type { MetadataRoute } from "next";

export default function sitemap(): MetadataRoute.Sitemap {
  const base = process.env.NEXT_PUBLIC_SITE_URL || "https://internship-tasks.vercel.app";
  const paths = ["/", "/products", "/about", "/quality", "/manufacturing", "/industries", "/global-reach", "/import-export", "/customers", "/vendor", "/blog", "/contact", "/quote"];
  return paths.map((path) => ({
    url: `${base.replace(/\/$/, "")}${path}`,
    changeFrequency: "weekly" as const,
    priority: path === "/" ? 1 : 0.7,
  }));
}
