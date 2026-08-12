import { prisma } from "@/lib/prisma";
import { PageHero } from "@/components/site/PageHero";
import { ProductCard } from "@/components/product/ProductCard";
import { buildMetadata, breadcrumbJsonLd } from "@/lib/seo";
import { JsonLd } from "@/components/site/JsonLd";
import { notFound } from "next/navigation";
import Link from "next/link";

export async function generateMetadata({
  params,
}: {
  params: Promise<{ category: string }>;
}) {
  const { category } = await params;
  const cat = await prisma.category.findUnique({ where: { slug: category } });
  if (!cat) return {};
  return buildMetadata({
    title: cat.seoTitle || cat.name,
    description: cat.seoDesc || cat.description,
    path: `/products/${cat.slug}`,
    image: cat.image,
    keywords: cat.seoKeywords,
  });
}

export default async function CategoryPage({
  params,
}: {
  params: Promise<{ category: string }>;
}) {
  const { category } = await params;
  const cat = await prisma.category.findUnique({
    where: { slug: category },
    include: { subcategories: { orderBy: { sortOrder: "asc" } } },
  });
  if (!cat) notFound();
  const products = await prisma.product.findMany({
    where: { published: true, categoryId: cat.id },
    include: { category: true, images: true },
    orderBy: { name: "asc" },
  });

  return (
    <>
      <JsonLd
        data={breadcrumbJsonLd([
          { name: "Home", path: "/" },
          { name: "Products", path: "/products" },
          { name: cat.name, path: `/products/${cat.slug}` },
        ])}
      />
      <PageHero eyebrow="Category" title={cat.name} subtitle={cat.description} image={cat.image} />
      <section className="surface-paper text-ink py-16">
        <div className="container-site">
          {cat.subcategories.length > 0 && (
            <div className="flex flex-wrap gap-2 mb-10">
              {cat.subcategories.map((s) => (
                <Link
                  key={s.id}
                  href={`/products?category=${cat.slug}&sub=${s.slug}`}
                  className="px-4 py-2 border border-black/15 text-sm tracking-wide uppercase"
                >
                  {s.name}
                </Link>
              ))}
            </div>
          )}
          <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-5">
            {products.map((p) => (
              <ProductCard key={p.id} product={p} />
            ))}
          </div>
        </div>
      </section>
    </>
  );
}
