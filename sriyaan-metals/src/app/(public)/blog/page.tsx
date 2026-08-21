import { prisma } from "@/lib/prisma";
import { PageHero } from "@/components/site/PageHero";
import { buildMetadata } from "@/lib/seo";
import { formatDate } from "@/lib/utils";
import Link from "next/link";

export const metadata = buildMetadata({
  title: "Blog",
  description:
    "Fastener guides, technical articles, export insights and company updates from SRIYAAN METALS.",
  path: "/blog",
});

export default async function BlogPage({
  searchParams,
}: {
  searchParams: Promise<{ q?: string; category?: string }>;
}) {
  const { q, category } = await searchParams;
  const [posts, categories] = await Promise.all([
    prisma.blog.findMany({
      where: {
        published: true,
        ...(category ? { category: { slug: category } } : {}),
        ...(q
          ? {
              OR: [
                { title: { contains: q } },
                { excerpt: { contains: q } },
                { content: { contains: q } },
              ],
            }
          : {}),
      },
      include: { category: true, author: true },
      orderBy: { publishedAt: "desc" },
    }),
    prisma.blogCategory.findMany({ orderBy: { name: "asc" } }),
  ]);
  const featured = posts.find((p) => p.featured) || posts[0];

  return (
    <>
      <PageHero
        eyebrow="Insights"
        title="Engineering notes from the shop floor"
        subtitle="Guides, specifications and export practice — written for buyers and engineers."
        image="/images/blog/grades.jpg"
      />
      <section className="surface-paper text-ink py-20">
        <div className="container-site">
          <form className="flex flex-wrap gap-3 mb-10">
            <input
              name="q"
              defaultValue={q}
              placeholder="Search articles"
              className="input max-w-sm"
            />
            <select name="category" defaultValue={category || ""} className="input max-w-xs">
              <option value="">All categories</option>
              {categories.map((c) => (
                <option key={c.id} value={c.slug}>
                  {c.name}
                </option>
              ))}
            </select>
            <button className="btn btn-dark">Filter</button>
          </form>

          {featured && (
            <Link
              href={`/blog/${featured.slug}`}
              className="grid lg:grid-cols-2 bg-white border border-black/8 mb-12 overflow-hidden"
            >
              <div className="img-zoom min-h-72">
                <img src={featured.image} alt={featured.title} className="h-full w-full object-cover" />
              </div>
              <div className="p-10">
                <p className="text-[0.7rem] tracking-[0.2em] uppercase text-brass-deep">
                  Featured · {featured.category.name}
                </p>
                <h2 className="display text-4xl mt-3">{featured.title}</h2>
                <p className="mt-4 text-[#5a616c]">{featured.excerpt}</p>
              </div>
            </Link>
          )}

          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
            {posts.map((post) => (
              <article key={post.id} className="bg-white border border-black/8">
                <Link href={`/blog/${post.slug}`} className="img-zoom block aspect-[16/10]">
                  <img src={post.image} alt={post.title} className="h-full w-full object-cover" />
                </Link>
                <div className="p-6">
                  <p className="text-[0.68rem] tracking-[0.18em] uppercase text-brass-deep">
                    {post.category.name} · {formatDate(post.publishedAt)}
                  </p>
                  <h3 className="mt-2 font-display text-2xl uppercase tracking-wide">
                    <Link href={`/blog/${post.slug}`}>{post.title}</Link>
                  </h3>
                  <p className="mt-3 text-sm text-[#5a616c]">{post.excerpt}</p>
                </div>
              </article>
            ))}
          </div>
        </div>
      </section>
    </>
  );
}
