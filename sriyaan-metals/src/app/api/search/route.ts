import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";

export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const q = searchParams.get("q")?.trim() || "";
  if (q.length < 2) return NextResponse.json({ products: [] });

  const products = await prisma.product.findMany({
    where: {
      published: true,
      OR: [
        { name: { contains: q } },
        { sku: { contains: q } },
        { material: { contains: q } },
        { grade: { contains: q } },
        { standard: { contains: q } },
        { application: { contains: q } },
        { category: { name: { contains: q } } },
      ],
    },
    include: { category: true, images: { take: 1 } },
    take: 12,
  });

  return NextResponse.json({
    products: products.map((p) => ({
      name: p.name,
      sku: p.sku,
      href: `/products/${p.category.slug}/${p.slug}`,
      image: p.images[0]?.url,
    })),
  });
}
