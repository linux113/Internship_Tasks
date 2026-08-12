import { prisma } from "@/lib/prisma";
import { ProductForm } from "@/components/admin/ProductForm";
import { notFound } from "next/navigation";

export default async function EditProduct({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const [product, categories, subcategories] = await Promise.all([
    prisma.product.findUnique({ where: { id }, include: { images: true } }),
    prisma.category.findMany({ orderBy: { name: "asc" } }),
    prisma.subcategory.findMany({ orderBy: { name: "asc" } }),
  ]);
  if (!product) notFound();
  return (
    <div>
      <h1 className="display text-4xl mb-8">Edit Product</h1>
      <ProductForm product={product} categories={categories} subcategories={subcategories} />
    </div>
  );
}
