import { prisma } from "@/lib/prisma";
import { buildMetadata, articleJsonLd, breadcrumbJsonLd } from "@/lib/seo";
import { JsonLd } from "@/components/site/JsonLd";
import { formatDate } from "@/lib/utils";
import { notFound } from "next/navigation";
import Link from "next/link";

export async function generateMetadata({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = await params;
  const post = await prisma.blog.findUnique({ where: { slug } });
  if (!post) return {};
  return buildMetadata({
    title: post.seoTitle || post.title,
    description: post.seoDesc || post.excerpt,
    path: `/blog/${post.slug}`,
    image: post.image,
    type: "article",
    keywords: post.seoKeywords,
  });
}

export default async function BlogDetail({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = await params;
  const post = await prisma.blog.findUnique({
    where: { slug },
    include: { category: true, author: true },
  });
  if (!post) notFound();
  const related = await prisma.blog.findMany({
    where: { published: true, categoryId: post.categoryId, id: { not: post.id } },
    take: 3,
  });

  return (
    <article className="pt-28 surface-paper text-ink">
      <JsonLd
        data={articleJsonLd({
          title: post.title,
          excerpt: post.excerpt,
          image: post.image,
          publishedAt: post.publishedAt,
          author: post.author.name,
          slug: post.slug,
        })}
      />
      <JsonLd
        data={breadcrumbJsonLd([
          { name: "Home", path: "/" },
          { name: "Blog", path: "/blog" },
          { name: post.title, path: `/blog/${post.slug}` },
        ])}
      />
      <div className="container-site py-12 max-w-3xl">
        <p className="text-[0.7rem] tracking-[0.2em] uppercase text-brass-deep">
          {post.category.name} · {formatDate(post.publishedAt)} · {post.author.name}
        </p>
        <h1 className="display text-5xl md:text-6xl mt-4">{post.title}</h1>
        <p className="mt-6 text-lg text-[#5a616c]">{post.excerpt}</p>
      </div>
      {post.image && (
        <div className="container-site max-w-5xl">
          <img src={post.image} alt={post.title} className="w-full max-h-[520px] object-cover" />
        </div>
      )}
      <div className="container-site py-14 max-w-3xl prose-like space-y-5 text-lg leading-relaxed text-[#2b3038] whitespace-pre-line">
        {post.content}
      </div>
      {related.length > 0 && (
        <div className="container-site pb-20">
          <h2 className="display text-3xl">Related articles</h2>
          <div className="mt-6 grid md:grid-cols-3 gap-5">
            {related.map((r) => (
              <Link key={r.id} href={`/blog/${r.slug}`} className="bg-white border border-black/8 p-5">
                <p className="font-display uppercase tracking-wide text-xl">{r.title}</p>
                <p className="mt-2 text-sm text-[#5a616c]">{r.excerpt}</p>
              </Link>
            ))}
          </div>
        </div>
      )}
    </article>
  );
}
