import type { Metadata } from "next";
import "./globals.css";
import { SiteChrome } from "@/components/SiteChrome";
import { company } from "@/lib/site-data";

export const metadata: Metadata = {
  metadataBase: new URL(company.domain),
  title: { default: "Sriyaan Metals | Industrial Fasteners", template: "%s | Sriyaan Metals" },
  description: "Industrial fasteners, standard and special products, technical sourcing and export support from Mumbai, India.",
  alternates: { canonical: "/" },
  openGraph: { title: "Sriyaan Metals", description: "Precision fasteners. Engineered supply. Global reach.", url: company.domain, siteName: "Sriyaan Metals", type: "website", images: ["/images/hero-fasteners.jpg"] },
  twitter: { card: "summary_large_image", images: ["/images/hero-fasteners.jpg"] },
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  const jsonLd = { "@context": "https://schema.org", "@type": "Organization", name: company.name, url: company.domain, email: company.email, telephone: company.phones[0], taxID: company.gst, address: { "@type": "PostalAddress", streetAddress: company.address, addressLocality: "Mumbai", addressRegion: "Maharashtra", postalCode: "400004", addressCountry: "IN" } };
  return <html lang="en"><body><script type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd).replace(/</g, "\\u003c") }} /><SiteChrome>{children}</SiteChrome></body></html>;
}
