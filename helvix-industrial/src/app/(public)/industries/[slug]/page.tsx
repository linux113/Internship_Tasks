import { prisma } from "@/lib/prisma";
import { PageHero } from "@/components/site/PageHero";
import { buildMetadata } from "@/lib/seo";
import { notFound } from "next/navigation";
import Link from "next/link";

export async function generateMetadata({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = await params;
  const ind = await prisma.industry.findUnique({ where: { slug } });
  if (!ind) return {};
  return buildMetadata({
    title: ind.seoTitle || ind.name,
    description: ind.seoDesc || ind.description,
    path: `/industries/${ind.slug}`,
    image: ind.image,
  });
}

export default async function IndustryDetail({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = await params;
  const ind = await prisma.industry.findUnique({ where: { slug } });
  if (!ind) notFound();
  return (
    <>
      <PageHero eyebrow="Industry" title={ind.name} subtitle={ind.description} image={ind.image} />
      <section className="surface-paper text-ink py-24">
        <div className="container-site max-w-3xl">
          <h2 className="display text-4xl">Applications</h2>
          <p className="mt-4 text-lg text-[#3d434c]">{ind.applications}</p>
          <div className="mt-10 flex gap-3">
            <Link href="/products" className="btn btn-dark">Related products</Link>
            <Link href="/quote" className="btn btn-primary">Get a Quote</Link>
          </div>
        </div>
      </section>
    </>
  );
}
