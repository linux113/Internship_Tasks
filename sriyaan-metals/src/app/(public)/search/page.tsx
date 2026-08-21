import { prisma } from "@/lib/prisma";
import { PageHero } from "@/components/site/PageHero";
import { ProductCard } from "@/components/product/ProductCard";
import { buildMetadata } from "@/lib/seo";

export const metadata = buildMetadata({
  title: "Search",
  description: "Search SRIYAAN METALS industrial fasteners by name, SKU, grade or standard.",
  path: "/search",
});

export default async function SearchPage({
  searchParams,
}: {
  searchParams: Promise<{ q?: string }>;
}) {
  const { q = "" } = await searchParams;
  const products = q
    ? await prisma.product.findMany({
        where: {
          published: true,
          OR: [
            { name: { contains: q } },
            { sku: { contains: q } },
            { material: { contains: q } },
            { grade: { contains: q } },
            { standard: { contains: q } },
            { application: { contains: q } },
          ],
        },
        include: { category: true, images: true },
        take: 24,
      })
    : [];

  return (
    <>
      <PageHero
        eyebrow="Search"
        title={q ? `Results for “${q}”` : "Search the catalogue"}
        image="/images/hero/hero-fasteners.jpg"
      />
      <section className="surface-paper text-ink py-16">
        <div className="container-site">
          <form className="max-w-xl mb-10">
            <input name="q" defaultValue={q} className="input" placeholder="Name, SKU, grade, standard" />
          </form>
          <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-5">
            {products.map((p) => (
              <ProductCard key={p.id} product={p} />
            ))}
          </div>
          {q && products.length === 0 && <p>No matching products.</p>}
        </div>
      </section>
    </>
  );
}
