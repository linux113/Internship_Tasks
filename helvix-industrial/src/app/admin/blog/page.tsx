import { prisma } from "@/lib/prisma";
import Link from "next/link";
import { deleteBlog } from "../actions";
import { formatDate } from "@/lib/utils";

export default async function AdminBlog() {
  const posts = await prisma.blog.findMany({
    include: { category: true, author: true },
    orderBy: { publishedAt: "desc" },
  });
  return (
    <div>
      <div className="flex justify-between items-center">
        <h1 className="display text-4xl">Blog</h1>
        <Link href="/admin/blog/new" className="btn btn-primary">
          New post
        </Link>
      </div>
      <table className="admin-table mt-8">
        <thead>
          <tr>
            <th>Title</th>
            <th>Category</th>
            <th>Author</th>
            <th>Date</th>
            <th></th>
          </tr>
        </thead>
        <tbody>
          {posts.map((p) => (
            <tr key={p.id}>
              <td>{p.title}</td>
              <td>{p.category.name}</td>
              <td>{p.author.name}</td>
              <td>{formatDate(p.publishedAt)}</td>
              <td className="flex gap-3">
                <Link href={`/admin/blog/${p.id}`} className="text-brass">
                  Edit
                </Link>
                <form action={deleteBlog}>
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
