"use server";

import { prisma } from "@/lib/prisma";
import { requireSession, hashPassword } from "@/lib/auth";
import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { slugify } from "@/lib/utils";

async function guard() {
  const s = await requireSession();
  if (!s) throw new Error("Unauthorized");
  return s;
}

export async function saveProduct(formData: FormData) {
  await guard();
  const id = String(formData.get("id") || "");
  const name = String(formData.get("name") || "");
  const data = {
    name,
    slug: String(formData.get("slug") || slugify(name)),
    sku: String(formData.get("sku") || ""),
    shortDesc: String(formData.get("shortDesc") || ""),
    description: String(formData.get("description") || ""),
    categoryId: String(formData.get("categoryId") || ""),
    subcategoryId: String(formData.get("subcategoryId") || "") || null,
    material: String(formData.get("material") || ""),
    grade: String(formData.get("grade") || ""),
    size: String(formData.get("size") || ""),
    diameter: String(formData.get("diameter") || ""),
    length: String(formData.get("length") || ""),
    standard: String(formData.get("standard") || ""),
    finish: String(formData.get("finish") || ""),
    threadType: String(formData.get("threadType") || ""),
    headType: String(formData.get("headType") || ""),
    application: String(formData.get("application") || ""),
    availability: String(formData.get("availability") || "In Stock"),
    features: String(formData.get("features") || ""),
    featured: formData.get("featured") === "on",
    published: formData.get("published") === "on",
    seoTitle: String(formData.get("seoTitle") || ""),
    seoDesc: String(formData.get("seoDesc") || ""),
    seoKeywords: String(formData.get("seoKeywords") || ""),
  };
  const imageUrl = String(formData.get("imageUrl") || "");
  const product = id
    ? await prisma.product.update({ where: { id }, data })
    : await prisma.product.create({ data });
  if (imageUrl) {
    await prisma.productImage.deleteMany({ where: { productId: product.id } });
    await prisma.productImage.create({
      data: { productId: product.id, url: imageUrl, alt: name },
    });
  }

  const specifications = String(formData.get("specifications") || "")
    .split("\n")
    .map((line) => line.trim())
    .filter(Boolean)
    .map((line, sortOrder) => {
      const separator = line.indexOf(":");
      return {
        productId: product.id,
        label: separator >= 0 ? line.slice(0, separator).trim() : line,
        value: separator >= 0 ? line.slice(separator + 1).trim() : "",
        sortOrder,
      };
    });
  await prisma.productSpecification.deleteMany({ where: { productId: product.id } });
  if (specifications.length > 0) {
    await prisma.productSpecification.createMany({ data: specifications });
  }

  revalidatePath("/admin/products");
  revalidatePath("/products");
  redirect("/admin/products");
}

export async function deleteProduct(formData: FormData) {
  await guard();
  await prisma.product.delete({ where: { id: String(formData.get("id")) } });
  revalidatePath("/admin/products");
}

export async function saveCategory(formData: FormData) {
  await guard();
  const id = String(formData.get("id") || "");
  const name = String(formData.get("name") || "");
  const data = {
    name,
    slug: String(formData.get("slug") || slugify(name)),
    shortDesc: String(formData.get("shortDesc") || ""),
    description: String(formData.get("description") || ""),
    image: String(formData.get("image") || ""),
    published: formData.get("published") !== "off",
    seoTitle: String(formData.get("seoTitle") || ""),
    seoDesc: String(formData.get("seoDesc") || ""),
  };
  if (id) await prisma.category.update({ where: { id }, data });
  else await prisma.category.create({ data });
  revalidatePath("/admin/categories");
  revalidatePath("/");
}

export async function deleteCategory(formData: FormData) {
  await guard();
  await prisma.category.delete({ where: { id: String(formData.get("id")) } });
  revalidatePath("/admin/categories");
}

export async function updateEnquiry(formData: FormData) {
  await guard();
  await prisma.enquiry.update({
    where: { id: String(formData.get("id")) },
    data: {
      status: String(formData.get("status") || "New"),
      notes: String(formData.get("notes") || ""),
    },
  });
  revalidatePath("/admin/enquiries");
}

export async function updateVendor(formData: FormData) {
  await guard();
  await prisma.vendor.update({
    where: { id: String(formData.get("id")) },
    data: {
      status: String(formData.get("status") || "New"),
      notes: String(formData.get("notes") || ""),
    },
  });
  revalidatePath("/admin/vendors");
}

export async function saveBlog(formData: FormData) {
  await guard();
  const id = String(formData.get("id") || "");
  const title = String(formData.get("title") || "");
  const data = {
    title,
    slug: String(formData.get("slug") || slugify(title)),
    excerpt: String(formData.get("excerpt") || ""),
    content: String(formData.get("content") || ""),
    image: String(formData.get("image") || ""),
    categoryId: String(formData.get("categoryId") || ""),
    authorId: String(formData.get("authorId") || ""),
    featured: formData.get("featured") === "on",
    published: formData.get("published") === "on",
    seoTitle: String(formData.get("seoTitle") || ""),
    seoDesc: String(formData.get("seoDesc") || ""),
  };
  if (id) await prisma.blog.update({ where: { id }, data });
  else await prisma.blog.create({ data });
  revalidatePath("/admin/blog");
  revalidatePath("/blog");
  redirect("/admin/blog");
}

export async function deleteBlog(formData: FormData) {
  await guard();
  await prisma.blog.delete({ where: { id: String(formData.get("id")) } });
  revalidatePath("/admin/blog");
}

export async function saveHomepage(formData: FormData) {
  await guard();
  await prisma.homepage.upsert({
    where: { id: "homepage" },
    update: {
      heroTitle: String(formData.get("heroTitle") || ""),
      heroSubtitle: String(formData.get("heroSubtitle") || ""),
      heroBg: String(formData.get("heroBg") || ""),
      heroFg: String(formData.get("heroFg") || ""),
      heroCtaText: String(formData.get("heroCtaText") || ""),
      heroCtaUrl: String(formData.get("heroCtaUrl") || ""),
      heroSecondaryText: String(formData.get("heroSecondaryText") || ""),
      heroSecondaryUrl: String(formData.get("heroSecondaryUrl") || ""),
      aboutTitle: String(formData.get("aboutTitle") || ""),
      aboutBody: String(formData.get("aboutBody") || ""),
      aboutImage: String(formData.get("aboutImage") || ""),
      ctaTitle: String(formData.get("ctaTitle") || ""),
      ctaBody: String(formData.get("ctaBody") || ""),
      importBody: String(formData.get("importBody") || ""),
      exportBody: String(formData.get("exportBody") || ""),
    },
    create: { id: "homepage" },
  });
  revalidatePath("/");
  revalidatePath("/admin/content");
}

export async function saveSettings(formData: FormData) {
  await guard();
  const keys = [
    "companyName",
    "legalName",
    "gst",
    "phone",
    "alternatePhone",
    "email",
    "salesEmail",
    "purchaseEmail",
    "accountsEmail",
    "whatsapp",
    "alternateWhatsapp",
    "officeAddress",
    "factoryAddress",
    "hours",
    "mapsEmbed",
    "linkedin",
    "instagram",
    "facebook",
    "youtube",
    "twitter",
    "gaId",
    "gscVerification",
  ];
  for (const key of keys) {
    await prisma.setting.upsert({
      where: { key },
      update: { value: String(formData.get(key) || "") },
      create: { key, value: String(formData.get(key) || "") },
    });
  }
  revalidatePath("/");
  revalidatePath("/admin/settings");
}

export async function saveCustomer(formData: FormData) {
  await guard();
  const id = String(formData.get("id") || "");
  const data = {
    name: String(formData.get("name") || ""),
    logo: String(formData.get("logo") || ""),
    website: String(formData.get("website") || ""),
    published: formData.get("published") !== "off",
  };
  if (id) await prisma.customer.update({ where: { id }, data });
  else await prisma.customer.create({ data });
  revalidatePath("/admin/customers");
}

export async function deleteCustomer(formData: FormData) {
  await guard();
  await prisma.customer.delete({ where: { id: String(formData.get("id")) } });
  revalidatePath("/admin/customers");
}

export async function saveTestimonial(formData: FormData) {
  await guard();
  await prisma.testimonial.create({
    data: {
      quote: String(formData.get("quote") || ""),
      name: String(formData.get("name") || ""),
      company: String(formData.get("company") || ""),
      designation: String(formData.get("designation") || ""),
    },
  });
  revalidatePath("/admin/customers");
}

export async function saveCertification(formData: FormData) {
  await guard();
  const id = String(formData.get("id") || "");
  const data = {
    name: String(formData.get("name") || ""),
    issuer: String(formData.get("issuer") || ""),
    certificateNumber: String(formData.get("certificateNumber") || ""),
    issueDate: formData.get("issueDate") ? new Date(String(formData.get("issueDate"))) : null,
    expiryDate: formData.get("expiryDate") ? new Date(String(formData.get("expiryDate"))) : null,
    description: String(formData.get("description") || ""),
    image: String(formData.get("image") || ""),
    fileUrl: String(formData.get("fileUrl") || ""),
  };
  if (id) await prisma.certification.update({ where: { id }, data });
  else await prisma.certification.create({ data });
  revalidatePath("/admin/certifications");
}

export async function deleteCertification(formData: FormData) {
  await guard();
  await prisma.certification.delete({ where: { id: String(formData.get("id")) } });
  revalidatePath("/admin/certifications");
}

export async function saveUser(formData: FormData) {
  const session = await guard();
  if (session.role !== "SUPER_ADMIN") throw new Error("Forbidden");
  const password = String(formData.get("password") || "");
  if (password.length < 12) throw new Error("Password must contain at least 12 characters");
  await prisma.user.create({
    data: {
      name: String(formData.get("name") || ""),
      email: String(formData.get("email") || ""),
      role: String(formData.get("role") || "CONTENT_MANAGER"),
      passwordHash: await hashPassword(password),
    },
  });
  revalidatePath("/admin/users");
}

export async function savePageSeo(formData: FormData) {
  await guard();
  const slug = String(formData.get("slug") || "");
  await prisma.pageContent.update({
    where: { slug },
    data: {
      seoTitle: String(formData.get("seoTitle") || ""),
      seoDesc: String(formData.get("seoDesc") || ""),
      seoKeywords: String(formData.get("seoKeywords") || ""),
      title: String(formData.get("title") || ""),
      subtitle: String(formData.get("subtitle") || ""),
      body: String(formData.get("body") || ""),
    },
  });
  revalidatePath("/admin/seo");
}

export async function saveCountry(formData: FormData) {
  await guard();
  await prisma.country.create({
    data: {
      name: String(formData.get("name") || ""),
      region: String(formData.get("region") || ""),
      flag: String(formData.get("flag") || ""),
      description: String(formData.get("description") || ""),
      lat: Number(formData.get("lat") || 0),
      lng: Number(formData.get("lng") || 0),
    },
  });
  revalidatePath("/admin/content");
  revalidatePath("/global-reach");
}

export async function saveWhy(formData: FormData) {
  await guard();
  await prisma.whyChoose.create({
    data: {
      title: String(formData.get("title") || ""),
      description: String(formData.get("description") || ""),
      icon: String(formData.get("icon") || "shield"),
    },
  });
  revalidatePath("/admin/content");
}

export async function saveIndustry(formData: FormData) {
  await guard();
  const name = String(formData.get("name") || "");
  await prisma.industry.create({
    data: {
      name,
      slug: String(formData.get("slug") || slugify(name)),
      description: String(formData.get("description") || ""),
      applications: String(formData.get("applications") || ""),
      image: String(formData.get("image") || ""),
      published: formData.get("published") === "on",
    },
  });
  revalidatePath("/admin/content");
  revalidatePath("/industries");
}

export async function deleteIndustry(formData: FormData) {
  await guard();
  await prisma.industry.delete({ where: { id: String(formData.get("id")) } });
  revalidatePath("/admin/content");
  revalidatePath("/industries");
}

export async function saveInfrastructure(formData: FormData) {
  await guard();
  await prisma.infrastructureImage.create({
    data: {
      title: String(formData.get("title") || ""),
      category: String(formData.get("category") || "Facility"),
      caption: String(formData.get("caption") || ""),
      image: String(formData.get("image") || ""),
      published: formData.get("published") === "on",
    },
  });
  revalidatePath("/admin/content");
  revalidatePath("/manufacturing");
}

export async function deleteInfrastructure(formData: FormData) {
  await guard();
  await prisma.infrastructureImage.delete({ where: { id: String(formData.get("id")) } });
  revalidatePath("/admin/content");
  revalidatePath("/manufacturing");
}
