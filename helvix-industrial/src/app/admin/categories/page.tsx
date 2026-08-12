import { prisma } from "@/lib/prisma";
import { deleteCategory, saveCategory } from "../actions";

export default async function AdminCategories() {
  const categories = await prisma.category.findMany({
    include: { _count: { select: { products: true, subcategories: true } } },
    orderBy: { sortOrder: "asc" },
  });
  return (
    <div>
      <h1 className="display text-4xl">Categories</h1>
      <form action={saveCategory} className="mt-8 grid md:grid-cols-2 gap-3 max-w-3xl dark-form">
        <input className="input" name="name" placeholder="Name" required />
        <input className="input" name="slug" placeholder="Slug" />
        <input className="input md:col-span-2" name="shortDesc" placeholder="Short description" />
        <input className="input md:col-span-2" name="image" placeholder="Image path" />
        <button className="btn btn-primary w-fit">Add category</button>
      </form>
      <table className="admin-table mt-10">
        <thead>
          <tr>
            <th>Name</th>
            <th>Slug</th>
            <th>Products</th>
            <th>Subs</th>
            <th></th>
          </tr>
        </thead>
        <tbody>
          {categories.map((c) => (
            <tr key={c.id}>
              <td>{c.name}</td>
              <td>{c.slug}</td>
              <td>{c._count.products}</td>
              <td>{c._count.subcategories}</td>
              <td>
                <form action={deleteCategory}>
                  <input type="hidden" name="id" value={c.id} />
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
