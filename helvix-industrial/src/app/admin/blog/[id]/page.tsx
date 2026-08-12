import { prisma } from "@/lib/prisma";
import { saveBlog } from "../../actions";
import { notFound } from "next/navigation";

export default async function EditBlog({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const [post, categories, authors] = await Promise.all([
    prisma.blog.findUnique({ where: { id } }),
    prisma.blogCategory.findMany(),
    prisma.blogAuthor.findMany(),
  ]);
  if (!post) notFound();
  return (
    <div>
      <h1 className="display text-4xl mb-8">Edit post</h1>
      <form action={saveBlog} className="grid gap-4 max-w-3xl dark-form">
        <input type="hidden" name="id" value={post.id} />
        <input className="input" name="title" defaultValue={post.title} />
        <input className="input" name="slug" defaultValue={post.slug} />
        <input className="input" name="image" defaultValue={post.image} />
        <select name="categoryId" defaultValue={post.categoryId} className="input">
          {categories.map((c) => (
            <option key={c.id} value={c.id}>
              {c.name}
            </option>
          ))}
        </select>
        <select name="authorId" defaultValue={post.authorId} className="input">
          {authors.map((a) => (
            <option key={a.id} value={a.id}>
              {a.name}
            </option>
          ))}
        </select>
        <textarea className="input min-h-20" name="excerpt" defaultValue={post.excerpt} />
        <textarea className="input min-h-48" name="content" defaultValue={post.content} />
        <input className="input" name="seoTitle" defaultValue={post.seoTitle} />
        <textarea className="input" name="seoDesc" defaultValue={post.seoDesc} />
        <label className="flex gap-2 text-sm">
          <input type="checkbox" name="featured" defaultChecked={post.featured} /> Featured
        </label>
        <label className="flex gap-2 text-sm">
          <input type="checkbox" name="published" defaultChecked={post.published} /> Published
        </label>
        <button className="btn btn-primary w-fit">Save</button>
      </form>
    </div>
  );
}
