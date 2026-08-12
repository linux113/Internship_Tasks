import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import { vendorSchema } from "@/lib/validations";
import { saveUpload } from "@/lib/upload";

export async function POST(request: Request) {
  const form = await request.formData();
  const parsed = vendorSchema.safeParse({
    companyName: form.get("companyName"),
    contactPerson: form.get("contactPerson"),
    email: form.get("email"),
    phone: form.get("phone") || "",
    country: form.get("country") || "",
    website: form.get("website") || "",
    categories: form.get("categories") || "",
    capability: form.get("capability") || "",
    certifications: form.get("certifications") || "",
    capacity: form.get("capacity") || "",
    message: form.get("message"),
    honeypot: form.get("honeypot") || "",
  });
  if (!parsed.success) {
    return NextResponse.json(
      { error: parsed.error.issues[0]?.message || "Invalid form" },
      { status: 400 },
    );
  }
  if (parsed.data.honeypot) return NextResponse.json({ ok: true });

  let profileUrl = "";
  try {
    profileUrl = await saveUpload(form.get("file") as File | null);
  } catch (e) {
    return NextResponse.json(
      { error: e instanceof Error ? e.message : "Upload failed" },
      { status: 400 },
    );
  }

  await prisma.vendor.create({
    data: {
      companyName: parsed.data.companyName,
      contactPerson: parsed.data.contactPerson,
      email: parsed.data.email,
      phone: parsed.data.phone || "",
      country: parsed.data.country || "",
      website: parsed.data.website || "",
      categories: parsed.data.categories || "",
      capability: parsed.data.capability || "",
      certifications: parsed.data.certifications || "",
      capacity: parsed.data.capacity || "",
      message: parsed.data.message,
      profileUrl,
    },
  });

  return NextResponse.json({ ok: true });
}
