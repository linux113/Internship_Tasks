import bcrypt from "bcryptjs";
import { prisma } from "../src/lib/prisma";

/**
 * Development seed for SRIYAAN METALS.
 *
 * Only client-supplied company details are published. Catalogue records,
 * certificates, customers, testimonials, countries and statistics are left
 * empty intentionally so no demo content can be mistaken for a real claim.
 */
async function main() {
  for (const model of [
    prisma.pageView,
    prisma.productDocument,
    prisma.productSpecification,
    prisma.productImage,
    prisma.enquiry,
    prisma.vendor,
    prisma.product,
    prisma.subcategory,
    prisma.category,
    prisma.blog,
    prisma.blogCategory,
    prisma.blogAuthor,
    prisma.customer,
    prisma.testimonial,
    prisma.certification,
    prisma.industry,
    prisma.country,
    prisma.whyChoose,
    prisma.infrastructureImage,
    prisma.homepage,
    prisma.pageContent,
    prisma.setting,
    prisma.mediaAsset,
    prisma.user,
  ]) {
    await model.deleteMany();
  }

  const bootstrapEmail = process.env.ADMIN_BOOTSTRAP_EMAIL || "admin@sriyaanmetals.co";
  const bootstrapPassword = process.env.ADMIN_BOOTSTRAP_PASSWORD || "ChangeMe-Sriyaan-2026!";
  const passwordHash = await bcrypt.hash(bootstrapPassword, 12);

  await prisma.user.create({
    data: {
      name: "SRIYAAN METALS Administrator",
      email: bootstrapEmail,
      passwordHash,
      role: "SUPER_ADMIN",
      active: true,
    },
  });

  const address =
    "FLOOR-2, 204, PLOT NO.96/98, Platinum Arcade, JSS Road, Central Plaza Cinema, Charni Road, Opera House, Mumbai - 400004, Maharashtra, India";

  const settings: Record<string, string> = {
    companyName: "SRIYAAN METALS",
    legalName: "SRIYAAN METALS",
    tagline: "Metals. Specifications. Business Enquiries.",
    gst: "27CRKPS0693G1ZB",
    phone: "+91 96195 61657",
    alternatePhone: "+91 98190 33982",
    email: "info@sriyaanmetals.co",
    salesEmail: "sales@sriyaanmetals.co",
    purchaseEmail: "purchase@sriyaanmetals.co",
    accountsEmail: "accounts@sriyaanmetals.co",
    whatsapp: "+91 96195 61657",
    alternateWhatsapp: "+91 98190 33982",
    officeAddress: address,
    factoryAddress: "",
    hours: "10:00 AM – 7:00 PM",
    mapsEmbed:
      "https://maps.google.com/maps?q=Platinum%20Arcade%20JSS%20Road%20Charni%20Road%20Mumbai%20400004&t=&z=15&ie=UTF8&iwloc=&output=embed",
    linkedin: "",
    instagram: "",
    facebook: "",
    youtube: "",
    twitter: "",
    gaId: "",
    gscVerification: "",
    logo: "/sriyaan-logo.jpeg",
    favicon: "/favicon.ico",
  };
  await prisma.setting.createMany({
    data: Object.entries(settings).map(([key, value]) => ({ key, value })),
  });

  await prisma.homepage.create({
    data: {
      id: "homepage",
      heroTitle: "Metal requirements.\nClear specifications.\nDirect response.",
      heroSubtitle:
        "Explore the SRIYAAN METALS catalogue as it is published, share your technical requirement, and request a commercial quotation from our Mumbai team.",
      heroBg: "/images/hero/hero-factory.jpg",
      heroFg: "/images/hero/hero-fasteners.jpg",
      heroCtaText: "Get a Quote",
      heroCtaUrl: "/quote",
      heroSecondaryText: "Explore Products",
      heroSecondaryUrl: "/products",
      aboutTitle: "Built around industrial enquiries",
      aboutBody:
        "SRIYAAN METALS is based in Opera House, Mumbai. This website is designed to make product discovery, specification sharing and business enquiries straightforward.\n\nProduct categories, technical data, certificates, infrastructure, customer references and export markets are managed through the secure CMS and are published only after client verification.",
      aboutImage: "/images/about/plant.jpg",
      aboutCta: "About SRIYAAN METALS",
      aboutCtaUrl: "/about",
      ctaTitle: "Tell us what you need.\nStart with a specification.",
      ctaBody:
        "Share the product, grade, size, quantity, standards and delivery destination available to you. Our team can respond using the contact details you provide.",
      ctaButton: "Send an Enquiry",
      ctaUrl: "/quote",
      importBody:
        "For import-related requirements, send the product description, origin preference, documentation needs and delivery location to our purchase team.",
      exportBody:
        "For export-related enquiries, share the destination, product specification, quantity and required documentation with our sales team.",
    },
  });

  await prisma.whyChoose.createMany({
    data: [
      {
        title: "Specification-led enquiries",
        description: "Forms capture product, quantity and technical details so your request starts with useful information.",
        icon: "grid",
        sortOrder: 0,
        published: true,
      },
      {
        title: "Direct contact channels",
        description: "Reach the company by enquiry form, telephone, email or pre-filled WhatsApp message.",
        icon: "clock",
        sortOrder: 1,
        published: true,
      },
      {
        title: "Verified catalogue content",
        description: "Products, specifications and documents are published through the CMS instead of being invented in templates.",
        icon: "shield",
        sortOrder: 2,
        published: true,
      },
    ],
  });

  const pages = [
    {
      slug: "about",
      title: "About SRIYAAN METALS",
      subtitle: "A B2B metals business based in Mumbai, India.",
      body: "SRIYAAN METALS operates from Platinum Arcade, JSS Road, Charni Road, Opera House, Mumbai.\n\nCompany history, mission, vision, business overview, capabilities and supporting images can be maintained here from the admin panel. They have intentionally not been invented for the initial release.",
      image: "/images/about/plant.jpg",
      seoTitle: "About SRIYAAN METALS | Mumbai",
      seoDesc: "Company information and contact details for SRIYAAN METALS in Mumbai, Maharashtra, India.",
    },
    {
      slug: "quality",
      title: "Quality & Certifications",
      subtitle: "Verified quality information will be published here.",
      body: "Certificates and quality documents are displayed only after they are uploaded and verified by an administrator.",
      image: "/images/factory/inspection.jpg",
      seoTitle: "Quality & Certifications | SRIYAAN METALS",
      seoDesc: "Verified quality and certification information published by SRIYAAN METALS.",
    },
    {
      slug: "manufacturing",
      title: "Infrastructure",
      subtitle: "Facility and process information managed through the CMS.",
      body: "Infrastructure, machinery, warehouse, packaging, inspection and production details will appear after they are supplied and approved by the client.",
      image: "/images/factory/cnc-mill.jpg",
      seoTitle: "Infrastructure | SRIYAAN METALS",
      seoDesc: "Infrastructure and facility information published by SRIYAAN METALS.",
    },
    {
      slug: "global-reach",
      title: "Global Reach",
      subtitle: "Configured markets and export information.",
      body: "Countries and market-specific information are shown only after they are configured in the admin panel. Contact the sales team to discuss your destination and requirements.",
      image: "/images/hero/hero-factory.jpg",
      seoTitle: "Global Enquiries | SRIYAAN METALS",
      seoDesc: "Discuss international product enquiries with SRIYAAN METALS.",
    },
    {
      slug: "import-export",
      title: "Import & Export",
      subtitle: "Share your product, destination and documentation requirements.",
      body: "Import and export capability details, countries and logistics information are CMS-controlled and will be published when supplied by the client.",
      image: "/images/factory/dispatch.jpg",
      seoTitle: "Import & Export Enquiries | SRIYAAN METALS",
      seoDesc: "Contact SRIYAAN METALS about import and export product requirements.",
    },
  ];
  await prisma.pageContent.createMany({ data: pages });

  await prisma.blogCategory.createMany({
    data: [
      { name: "Industry Knowledge", slug: "industry-knowledge" },
      { name: "Product Guides", slug: "product-guides" },
      { name: "Company Updates", slug: "company-updates" },
    ],
  });

  console.log(`Seeded SRIYAAN METALS CMS. Admin: ${bootstrapEmail}`);
  if (!process.env.ADMIN_BOOTSTRAP_PASSWORD) {
    console.log("Development password: ChangeMe-Sriyaan-2026! (change before deployment)");
  }
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
