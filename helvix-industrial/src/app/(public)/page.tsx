import { prisma } from "@/lib/prisma";
import { getHomepage, getSettings } from "@/lib/cms";
import { Hero } from "@/components/home/Hero";
import { CategoryGrid } from "@/components/home/CategoryGrid";
import { AboutSplit } from "@/components/home/AboutSplit";
import { WhyChoose } from "@/components/home/WhyChoose";
import { QualityStrip } from "@/components/home/QualityStrip";
import { Manufacturing } from "@/components/home/Manufacturing";
import { IndustryGrid } from "@/components/home/IndustryGrid";
import { GlobalMap } from "@/components/home/GlobalMap";
import { ImportExport } from "@/components/home/ImportExport";
import { FeaturedProducts } from "@/components/home/FeaturedProducts";
import { Customers } from "@/components/home/Customers";
import { Testimonials } from "@/components/home/Testimonials";
import { MainCta } from "@/components/home/MainCta";
import { LatestBlogs } from "@/components/home/LatestBlogs";
import { HomeContact } from "@/components/home/HomeContact";

export const dynamic = "force-dynamic";

export default async function HomePage() {
  const [
    home,
    settings,
    categories,
    why,
    certs,
    infra,
    industries,
    countries,
    featured,
    customers,
    testimonials,
    posts,
  ] = await Promise.all([
    getHomepage(),
    getSettings(),
    prisma.category.findMany({
      where: { published: true },
      orderBy: { sortOrder: "asc" },
    }),
    prisma.whyChoose.findMany({
      where: { published: true },
      orderBy: { sortOrder: "asc" },
    }),
    prisma.certification.findMany({
      where: { published: true },
      orderBy: { sortOrder: "asc" },
    }),
    prisma.infrastructureImage.findMany({
      where: { published: true },
      orderBy: { sortOrder: "asc" },
    }),
    prisma.industry.findMany({
      where: { published: true },
      orderBy: { sortOrder: "asc" },
    }),
    prisma.country.findMany({
      where: { published: true },
      orderBy: { sortOrder: "asc" },
    }),
    prisma.product.findMany({
      where: { featured: true, published: true },
      include: { category: true, images: { orderBy: { sortOrder: "asc" } } },
      take: 8,
    }),
    prisma.customer.findMany({
      where: { published: true },
      orderBy: { sortOrder: "asc" },
    }),
    prisma.testimonial.findMany({
      where: { published: true },
      orderBy: { sortOrder: "asc" },
    }),
    prisma.blog.findMany({
      where: { published: true },
      include: { category: true },
      orderBy: { publishedAt: "desc" },
      take: 3,
    }),
  ]);

  return (
    <>
      <Hero
        title={home?.heroTitle || "Precision Fasteners.\nReliable Supply.\nGlobal Reach."}
        subtitle={
          home?.heroSubtitle ||
          "High-quality industrial fasteners engineered for demanding applications."
        }
        bg={home?.heroBg || "/images/hero/hero-factory.jpg"}
        fg={home?.heroFg || "/images/hero/hero-fasteners.jpg"}
        ctaText={home?.heroCtaText || "Get a Quote"}
        ctaUrl={home?.heroCtaUrl || "/quote"}
        secondaryText={home?.heroSecondaryText || "Send Enquiry"}
        secondaryUrl={home?.heroSecondaryUrl || "/contact"}
      />
      <CategoryGrid categories={categories} />
      <AboutSplit
        title={home?.aboutTitle || "About Our Company"}
        body={home?.aboutBody || ""}
        image={home?.aboutImage || "/images/about/plant.jpg"}
        cta={home?.aboutCta || "Know More About Us"}
        ctaUrl={home?.aboutCtaUrl || "/about"}
      />
      <WhyChoose items={why} />
      <QualityStrip items={certs} />
      <Manufacturing images={infra} />
      <IndustryGrid industries={industries} />
      <GlobalMap countries={countries} />
      <ImportExport importBody={home?.importBody || ""} exportBody={home?.exportBody || ""} />
      <FeaturedProducts products={featured} />
      <Customers customers={customers} />
      <Testimonials items={testimonials} />
      <MainCta
        title={home?.ctaTitle || "Specify the fastener.\nWe will engineer the supply."}
        body={home?.ctaBody || ""}
        button={home?.ctaButton || "Get a Quote"}
        url={home?.ctaUrl || "/quote"}
        image="/images/hero/hero-factory.jpg"
      />
      <LatestBlogs posts={posts} />
      <HomeContact
        phone={settings.phone || ""}
        email={settings.email || ""}
        address={settings.factoryAddress || ""}
      />
    </>
  );
}
