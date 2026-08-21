import type { Metadata } from "next";
import "@fontsource/outfit/400.css";
import "@fontsource/outfit/500.css";
import "@fontsource/outfit/600.css";
import "@fontsource/barlow-condensed/600.css";
import "@fontsource/barlow-condensed/700.css";
import "./globals.css";
import { getSettings } from "@/lib/cms";
import { buildMetadata, organizationJsonLd } from "@/lib/seo";
import { JsonLd } from "@/components/site/JsonLd";

export async function generateMetadata(): Promise<Metadata> {
  const s = await getSettings();
  return {
    ...buildMetadata({
      title: s.companyName
        ? `${s.companyName} | B2B Metals & Product Enquiries`
        : "SRIYAAN METALS | B2B Metals & Product Enquiries",
      description:
        s.tagline ||
        "Explore verified products and send commercial enquiries to SRIYAAN METALS in Mumbai, India.",
      path: "/",
    }),
    metadataBase: new URL(process.env.NEXT_PUBLIC_SITE_URL || "http://localhost:3000"),
    icons: { icon: "/sriyaan-logo.jpeg" },
  };
}

export default async function RootLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  const settings = await getSettings();
  return (
    <html lang="en" className="h-full antialiased">
      <body className="min-h-full flex flex-col bg-ink text-paper font-sans">
        <JsonLd data={organizationJsonLd(settings)} />
        {children}
      </body>
    </html>
  );
}
