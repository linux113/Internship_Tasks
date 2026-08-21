import { prisma } from "@/lib/prisma";
import Link from "next/link";
import { deleteProduct } from "../actions";

export default async function AdminProducts() {
  const products = await prisma.product.findMany({
    include: { category: true },
    orderBy: { updatedAt: "desc" },
  });
  return (
    <div>
      <div className="flex items-center justify-between">
        <h1 className="display text-4xl">Products</h1>
        <Link href="/admin/products/new" className="btn btn-primary">
          Add Product
        </Link>
      </div>
      <table className="admin-table mt-8">
        <thead>
          <tr>
            <th>Name</th>
            <th>SKU</th>
            <th>Category</th>
            <th>Featured</th>
            <th>Status</th>
            <th></th>
          </tr>
        </thead>
        <tbody>
          {products.map((p) => (
            <tr key={p.id}>
              <td>{p.name}</td>
              <td>{p.sku}</td>
              <td>{p.category.name}</td>
              <td>{p.featured ? "Yes" : "—"}</td>
              <td>{p.published ? "Live" : "Draft"}</td>
              <td className="flex gap-3">
                <Link href={`/admin/products/${p.id}`} className="text-brass">
                  Edit
                </Link>
                <form action={deleteProduct}>
                  <input type="hidden" name="id" value={p.id} />
                  <button className="text-copper">Delete</button>
                </form>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
