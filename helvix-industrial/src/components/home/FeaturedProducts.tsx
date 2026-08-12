import { ProductCard } from "@/components/product/ProductCard";
import { Reveal } from "@/components/site/Reveal";
import Link from "next/link";

export function FeaturedProducts({
  products,
}: {
  products: Parameters<typeof ProductCard>[0]["product"][];
}) {
  return (
    <section className="surface-paper py-24">
      <div className="container-site">
        <Reveal>
          <div className="flex flex-col md:flex-row md:items-end md:justify-between gap-6">
            <div>
              <p className="eyebrow">Selection</p>
              <h2 className="display text-5xl md:text-6xl text-ink mt-4">Featured Products</h2>
            </div>
            <Link href="/products" className="link-underline uppercase tracking-[0.16em] text-sm">
              Browse catalogue
            </Link>
          </div>
        </Reveal>
        <div className="mt-14 grid sm:grid-cols-2 lg:grid-cols-4 gap-5">
          {products.map((p) => (
            <ProductCard key={p.slug} product={p} />
          ))}
        </div>
      </div>
    </section>
  );
}
