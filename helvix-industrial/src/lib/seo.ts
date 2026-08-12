import type { Metadata } from "next";
import { siteUrl, truncate } from "./utils";

type SeoInput = {
  title: string;
  description: string;
  path?: string;
  image?: string;
  keywords?: string;
  type?: "website" | "article";
};

export function buildMetadata({
  title,
  description,
  path = "/",
  image = "/images/hero/hero-factory.jpg",
  keywords,
  type = "website",
}: SeoInput): Metadata {
  const url = siteUrl(path);
  const fullTitle = title.includes("Helvix")
    ? title
    : `${title} | Helvix Industrial`;

  return {
    title: fullTitle,
    description: truncate(description, 168),
    keywords: keywords || undefined,
    alternates: { canonical: url },
    openGraph: {
      title: fullTitle,
      description: truncate(description, 168),
      url,
      siteName: "Helvix Industrial",
      type,
      images: [{ url: siteUrl(image), width: 1200, height: 630 }],
    },
    twitter: {
      card: "summary_large_image",
      title: fullTitle,
      description: truncate(description, 168),
      images: [siteUrl(image)],
    },
  };
}

export function organizationJsonLd(settings: Record<string, string>) {
  return {
    "@context": "https://schema.org",
    "@type": "Organization",
    name: settings.companyName || "Helvix Industrial",
    url: siteUrl("/"),
    logo: siteUrl("/logo.svg"),
    telephone: settings.phone,
    email: settings.email,
    address: {
      "@type": "PostalAddress",
      streetAddress: settings.officeAddress || settings.address,
      addressCountry: "IN",
    },
    sameAs: [
      settings.linkedin,
      settings.instagram,
      settings.facebook,
      settings.youtube,
    ].filter(Boolean),
  };
}

export function productJsonLd(product: {
  name: string;
  description: string;
  sku: string;
  image?: string;
  material?: string;
}) {
  return {
    "@context": "https://schema.org",
    "@type": "Product",
    name: product.name,
    description: product.description,
    sku: product.sku,
    image: product.image ? siteUrl(product.image) : undefined,
    brand: { "@type": "Brand", name: "Helvix Industrial" },
    material: product.material || undefined,
    manufacturer: {
      "@type": "Organization",
      name: "Helvix Industrial",
    },
  };
}

export function articleJsonLd(post: {
  title: string;
  excerpt: string;
  image?: string;
  publishedAt: Date;
  author: string;
  slug: string;
}) {
  return {
    "@context": "https://schema.org",
    "@type": "Article",
    headline: post.title,
    description: post.excerpt,
    image: post.image ? siteUrl(post.image) : undefined,
    datePublished: new Date(post.publishedAt || Date.now()).toISOString(),
    author: { "@type": "Person", name: post.author },
    publisher: {
      "@type": "Organization",
      name: "Helvix Industrial",
      logo: { "@type": "ImageObject", url: siteUrl("/logo.svg") },
    },
    mainEntityOfPage: siteUrl(`/blog/${post.slug}`),
  };
}

export function breadcrumbJsonLd(items: { name: string; path: string }[]) {
  return {
    "@context": "https://schema.org",
    "@type": "BreadcrumbList",
    itemListElement: items.map((item, index) => ({
      "@type": "ListItem",
      position: index + 1,
      name: item.name,
      item: siteUrl(item.path),
    })),
  };
}
