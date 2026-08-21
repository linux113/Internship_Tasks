import { prisma } from "@/lib/prisma";
import { ProductForm } from "@/components/admin/ProductForm";

export default async function NewProduct() {
  const [categories, subcategories] = await Promise.all([
    prisma.category.findMany({ orderBy: { name: "asc" } }),
    prisma.subcategory.findMany({ orderBy: { name: "asc" } }),
  ]);
  return (
    <div>
      <h1 className="display text-4xl mb-8">Add Product</h1>
      <ProductForm categories={categories} subcategories={subcategories} />
    </div>
  );
}
