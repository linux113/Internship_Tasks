import { prisma } from "@/lib/prisma";
import { savePageSeo } from "../actions";

export default async function AdminSeo() {
  const pages = await prisma.pageContent.findMany();
  return (
    <div>
      <h1 className="display text-4xl">SEO</h1>
      <p className="text-mist mt-2">Page-level titles, descriptions and body copy.</p>
      <div className="mt-10 space-y-10">
        {pages.map((p) => (
          <form key={p.slug} action={savePageSeo} className="border border-white/10 p-6 grid gap-3 dark-form">
            <input type="hidden" name="slug" value={p.slug} />
            <p className="font-display uppercase tracking-wide text-brass">{p.slug}</p>
            <input className="input" name="title" defaultValue={p.title} />
            <input className="input" name="subtitle" defaultValue={p.subtitle} />
            <textarea className="input min-h-24" name="body" defaultValue={p.body} />
            <input className="input" name="seoTitle" defaultValue={p.seoTitle} placeholder="SEO title" />
            <textarea className="input" name="seoDesc" defaultValue={p.seoDesc} placeholder="Meta description" />
            <input className="input" name="seoKeywords" defaultValue={p.seoKeywords} placeholder="Keywords" />
            <button className="btn btn-primary w-fit">Save {p.slug}</button>
          </form>
        ))}
      </div>
    </div>
  );
}
