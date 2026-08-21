import type { MetadataRoute } from "next";
import { categories, company, products } from "@/lib/site-data";

export default function sitemap(): MetadataRoute.Sitemap {
  const pages=["","products","about","quality","infrastructure","industries","global-reach","import-export","vendor","blog","contact","quote"];
  return [...pages.map(path=>({url:`${company.domain}/${path}`,changeFrequency:"weekly" as const,priority:path===""?1:path==="products"?0.9:0.7})),...products.map(p=>({url:`${company.domain}/products/${p.slug}`,changeFrequency:"monthly" as const,priority:.8})),...categories.map(c=>({url:`${company.domain}/products?category=${c.slug}`,changeFrequency:"weekly" as const,priority:.7}))];
}
