import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import { enquirySchema } from "@/lib/validations";
import { saveUpload } from "@/lib/upload";
import { sendEnquiryNotification } from "@/lib/email";

const hits = new Map<string, { n: number; t: number }>();

function limited(ip: string) {
  const now = Date.now();
  const rec = hits.get(ip);
  if (!rec || now - rec.t > 60_000) {
    hits.set(ip, { n: 1, t: now });
    return false;
  }
  rec.n += 1;
  return rec.n > 8;
}

export async function POST(request: Request) {
  const ip = request.headers.get("x-forwarded-for") || "local";
  if (limited(ip)) {
    return NextResponse.json({ error: "Too many requests" }, { status: 429 });
  }

  const form = await request.formData();
  if (String(form.get("website") || "")) {
    return NextResponse.json({ ok: true });
  }

  const parsed = enquirySchema.safeParse({
    name: form.get("name"),
    company: form.get("company") || "",
    email: form.get("email"),
    phone: form.get("phone") || "",
    country: form.get("country") || "",
    subject: form.get("subject") || "",
    product: form.get("product") || "",
    productId: form.get("productId") || "",
    quantity: form.get("quantity") || "",
    spec: form.get("spec") || "",
    message: form.get("message"),
    type: form.get("type") || "general",
  });
  if (!parsed.success) {
    return NextResponse.json(
      { error: parsed.error.issues[0]?.message || "Invalid form" },
      { status: 400 },
    );
  }

  let fileUrl = "";
  try {
    fileUrl = await saveUpload(form.get("file") as File | null);
  } catch (e) {
    return NextResponse.json(
      { error: e instanceof Error ? e.message : "Upload failed" },
      { status: 400 },
    );
  }

  const productId = parsed.data.productId || null;
  const product = productId
    ? await prisma.product.findUnique({ where: { id: productId } })
    : null;

  await prisma.enquiry.create({
    data: {
      type: parsed.data.type || "general",
      name: parsed.data.name,
      company: parsed.data.company || "",
      email: parsed.data.email,
      phone: parsed.data.phone || "",
      country: parsed.data.country || "",
      subject: parsed.data.subject || "",
      productId: product?.id,
      productName: parsed.data.product || product?.name || "",
      quantity: parsed.data.quantity || "",
      spec: parsed.data.spec || "",
      message: parsed.data.message,
      fileUrl,
    },
  });

  try {
    await sendEnquiryNotification({
      type: parsed.data.type || "general",
      name: parsed.data.name,
      company: parsed.data.company,
      email: parsed.data.email,
      phone: parsed.data.phone,
      country: parsed.data.country,
      product: parsed.data.product || product?.name,
      quantity: parsed.data.quantity,
      message: parsed.data.message,
    });
  } catch (error) {
    // The database record is the source of truth; transient SMTP failures do not
    // discard a valid lead and can be retried from the admin workflow.
    console.error("Enquiry notification failed", error instanceof Error ? error.message : error);
  }

  return NextResponse.json({ ok: true });
}
