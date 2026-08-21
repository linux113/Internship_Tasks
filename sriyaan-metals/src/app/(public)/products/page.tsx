import { prisma } from "@/lib/prisma";
import { PageHero } from "@/components/site/PageHero";
import { ProductCard } from "@/components/product/ProductCard";
import { buildMetadata } from "@/lib/seo";
import Link from "next/link";

export const metadata = buildMetadata({
  title: "Product Catalogue",
  description:
    "Browse verified products and technical specifications published by SRIYAAN METALS.",
  path: "/products",
});

export default async function ProductsPage({
  searchParams,
}: {
  searchParams: Promise<Record<string, string | undefined>>;
}) {
  const sp = await searchParams;
  const page = Math.max(1, Number(sp.page || 1));
  const take = 12;
  const where = {
    published: true,
    ...(sp.category ? { category: { slug: sp.category } } : {}),
    ...(sp.sub ? { subcategory: { slug: sp.sub } } : {}),
    ...(sp.material ? { material: { contains: sp.material } } : {}),
    ...(sp.grade ? { grade: { contains: sp.grade } } : {}),
    ...(sp.size ? { size: { contains: sp.size } } : {}),
    ...(sp.application ? { application: { contains: sp.application } } : {}),
    ...(sp.q
      ? {
          OR: [
            { name: { contains: sp.q } },
            { sku: { contains: sp.q } },
            { material: { contains: sp.q } },
            { grade: { contains: sp.q } },
            { standard: { contains: sp.q } },
            { application: { contains: sp.q } },
          ],
        }
      : {}),
  };

  const [total, products, categories] = await Promise.all([
    prisma.product.count({ where }),
    prisma.product.findMany({
      where,
      include: { category: true, images: { orderBy: { sortOrder: "asc" } } },
      orderBy:
        sp.sort === "name"
          ? { name: "asc" }
          : sp.sort === "sku"
            ? { sku: "asc" }
            : { featured: "desc" },
      skip: (page - 1) * take,
      take,
    }),
    prisma.category.findMany({
      where: { published: true },
      include: { subcategories: { orderBy: { sortOrder: "asc" } } },
      orderBy: { sortOrder: "asc" },
    }),
  ]);
  const pages = Math.max(1, Math.ceil(total / take));

  return (
    <>
      <PageHero
        eyebrow="Catalogue"
        title="Product Catalogue"
        subtitle="Search published products by name, standard, grade, size and application."
        image="/images/hero/hero-fasteners.jpg"
      />
      <section className="surface-paper text-ink py-16">
        <div className="container-site grid lg:grid-cols-12 gap-10">
          <aside className="lg:col-span-3">
            <form className="space-y-3 sticky top-28">
              <input name="q" defaultValue={sp.q} placeholder="Search name, SKU, grade" className="input" />
              <select name="category" defaultValue={sp.category || ""} className="input">
                <option value="">All categories</option>
                {categories.map((c) => (
                  <option key={c.id} value={c.slug}>
                    {c.name}
                  </option>
                ))}
              </select>
              <input name="material" defaultValue={sp.material} placeholder="Material" className="input" />
              <input name="grade" defaultValue={sp.grade} placeholder="Grade" className="input" />
              <input name="size" defaultValue={sp.size} placeholder="Size" className="input" />
              <input name="application" defaultValue={sp.application} placeholder="Application" className="input" />
              <select name="sort" defaultValue={sp.sort || ""} className="input">
                <option value="">Featured</option>
                <option value="name">Name</option>
                <option value="sku">SKU</option>
              </select>
              <button className="btn btn-dark w-full">Apply filters</button>
            </form>
          </aside>
          <div className="lg:col-span-9">
            <p className="text-sm text-[#6b7280] mb-6">{total} products</p>
            <div className="grid sm:grid-cols-2 xl:grid-cols-3 gap-5">
              {products.map((p) => (
                <ProductCard key={p.id} product={p} />
              ))}
            </div>
            {products.length === 0 && (
              <div className="border border-black/10 bg-white p-8">
                <p className="font-display text-2xl uppercase tracking-wide">No published products found</p>
                <p className="mt-2 text-[#5a616c]">The catalogue is CMS-driven and awaiting verified client content.</p>
                <Link href="/quote" className="btn btn-dark mt-6">Send a custom requirement</Link>
              </div>
            )}
            <div className="mt-10 flex gap-2">
              {Array.from({ length: pages }, (_, i) => i + 1).map((n) => (
                <Link
                  key={n}
                  href={`/products?${new URLSearchParams({ ...sp, page: String(n) } as Record<string, string>).toString()}`}
                  className={`px-3 py-2 border ${n === page ? "bg-ink text-paper" : "border-black/15"}`}
                >
                  {n}
                </Link>
              ))}
            </div>
          </div>
        </div>
      </section>
    </>
  );
}
