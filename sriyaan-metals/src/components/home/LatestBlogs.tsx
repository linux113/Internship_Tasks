import Link from "next/link";
import { formatDate } from "@/lib/utils";
import { Reveal } from "@/components/site/Reveal";

export function LatestBlogs({
  posts,
}: {
  posts: {
    id: string;
    title: string;
    slug: string;
    excerpt: string;
    image: string;
    publishedAt: Date;
    category: { name: string };
  }[];
}) {
  return (
    <section className="surface-paper py-24">
      <div className="container-site">
        <Reveal>
          <div className="flex items-end justify-between gap-6">
            <div>
              <p className="eyebrow">Insights</p>
              <h2 className="display text-5xl text-ink mt-4">Latest Blogs</h2>
            </div>
            <Link href="/blog" className="link-underline uppercase tracking-[0.16em] text-sm">
              All articles
            </Link>
          </div>
        </Reveal>
        <div className="mt-14 grid lg:grid-cols-3 gap-6">
          {posts.map((post) => (
            <article key={post.id} className="bg-white border border-black/8">
              <Link href={`/blog/${post.slug}`} className="img-zoom block aspect-[16/10]">
                <img src={post.image} alt={post.title} className="h-full w-full object-cover" />
              </Link>
              <div className="p-6">
                <p className="text-[0.68rem] tracking-[0.2em] uppercase text-brass-deep">
                  {post.category.name} · {formatDate(post.publishedAt)}
                </p>
                <h3 className="mt-3 font-display text-2xl uppercase tracking-wide text-ink">
                  <Link href={`/blog/${post.slug}`}>{post.title}</Link>
                </h3>
                <p className="mt-3 text-sm text-[#5a616c]">{post.excerpt}</p>
              </div>
            </article>
          ))}
        </div>
      </div>
    </section>
  );
}
