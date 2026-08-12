import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import { enquirySchema } from "@/lib/validations";
import { saveUpload } from "@/lib/upload";

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
      productId: product?.id,
      productName: parsed.data.product || product?.name || "",
      quantity: parsed.data.quantity || "",
      spec: parsed.data.spec || "",
      message: parsed.data.message,
      fileUrl,
    },
  });

  return NextResponse.json({ ok: true });
}
