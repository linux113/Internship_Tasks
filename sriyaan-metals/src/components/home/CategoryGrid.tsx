import Link from "next/link";
import { Reveal } from "@/components/site/Reveal";

type Cat = {
  id: string;
  name: string;
  slug: string;
  shortDesc: string;
  image: string;
};

export function CategoryGrid({ categories }: { categories: Cat[] }) {
  return (
    <section className="surface-paper py-24">
      <div className="container-site">
        <Reveal>
          <p className="eyebrow">Catalogue</p>
          <div className="mt-4 flex flex-col md:flex-row md:items-end md:justify-between gap-6">
            <h2 className="display text-5xl md:text-6xl text-ink">Our Product Range</h2>
            <Link href="/products" className="link-underline text-sm tracking-[0.16em] uppercase">
              View full catalogue
            </Link>
          </div>
        </Reveal>
        <div className="mt-14 grid sm:grid-cols-2 lg:grid-cols-3 gap-5">
          {categories.length === 0 && (
            <div className="sm:col-span-2 lg:col-span-3 border border-black/10 bg-white p-8 md:p-12 flex flex-col md:flex-row md:items-center md:justify-between gap-6">
              <div>
                <p className="font-display text-2xl uppercase tracking-wide text-ink">Catalogue content is being prepared</p>
                <p className="mt-2 text-[#5a616c]">Send your product name, grade, size and quantity for a direct quotation.</p>
              </div>
              <Link href="/quote" className="btn btn-dark shrink-0">Send requirement</Link>
            </div>
          )}
          {categories.map((cat, i) => (
            <Reveal key={cat.id} delay={i * 0.06}>
              <Link
                href={`/products/${cat.slug}`}
                className="group block bg-white border border-black/8 card-hover"
              >
                <div className="img-zoom aspect-[16/10]">
                  <img
                    src={cat.image}
                    alt={cat.name}
                    className="h-full w-full object-cover"
                  />
                </div>
                <div className="p-6">
                  <h3 className="font-display text-3xl tracking-wide uppercase text-ink">
                    {cat.name}
                  </h3>
                  <p className="mt-2 text-sm text-[#5a616c] leading-relaxed">
                    {cat.shortDesc}
                  </p>
                  <span className="mt-5 inline-block text-[0.7rem] tracking-[0.2em] uppercase text-brass-deep">
                    Explore Products →
                  </span>
                </div>
              </Link>
            </Reveal>
          ))}
        </div>
      </div>
    </section>
  );
}
