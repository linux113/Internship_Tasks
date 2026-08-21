import { prisma } from "@/lib/prisma";
import { saveBlog } from "../../actions";

export default async function NewBlog() {
  const [categories, authors] = await Promise.all([
    prisma.blogCategory.findMany(),
    prisma.blogAuthor.findMany(),
  ]);
  return (
    <div>
      <h1 className="display text-4xl mb-8">New post</h1>
      <form action={saveBlog} className="grid gap-4 max-w-3xl dark-form">
        <input className="input" name="title" placeholder="Title" required />
        <input className="input" name="slug" placeholder="Slug" />
        <input className="input" name="image" placeholder="Image path" />
        <select name="categoryId" className="input">
          {categories.map((c) => (
            <option key={c.id} value={c.id}>
              {c.name}
            </option>
          ))}
        </select>
        <select name="authorId" className="input">
          {authors.map((a) => (
            <option key={a.id} value={a.id}>
              {a.name}
            </option>
          ))}
        </select>
        <textarea className="input min-h-20" name="excerpt" placeholder="Excerpt" />
        <textarea className="input min-h-48" name="content" placeholder="Content (markdown-ish text)" />
        <input className="input" name="seoTitle" placeholder="SEO title" />
        <textarea className="input" name="seoDesc" placeholder="Meta description" />
        <label className="flex gap-2 text-sm">
          <input type="checkbox" name="featured" /> Featured
        </label>
        <label className="flex gap-2 text-sm">
          <input type="checkbox" name="published" defaultChecked /> Published
        </label>
        <button className="btn btn-primary w-fit">Publish</button>
      </form>
    </div>
  );
}
