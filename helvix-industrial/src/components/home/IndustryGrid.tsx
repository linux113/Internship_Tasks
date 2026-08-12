import Link from "next/link";
import { Reveal } from "@/components/site/Reveal";

export function IndustryGrid({
  industries,
}: {
  industries: { id: string; name: string; slug: string; description: string; image: string }[];
}) {
  return (
    <section className="surface-paper py-24">
      <div className="container-site">
        <Reveal>
          <p className="eyebrow">Markets</p>
          <h2 className="display text-5xl md:text-6xl text-ink mt-4">Industries We Serve</h2>
        </Reveal>
        <div className="mt-14 grid sm:grid-cols-2 lg:grid-cols-5 gap-3">
          {industries.map((ind, i) => (
            <Reveal key={ind.id} delay={i * 0.03}>
              <Link href={`/industries/${ind.slug}`} className="group relative block aspect-[4/5] overflow-hidden bg-ink">
                <img
                  src={ind.image}
                  alt={ind.name}
                  className="absolute inset-0 h-full w-full object-cover opacity-70 group-hover:scale-105 transition-transform duration-700"
                />
                <div className="absolute inset-0 bg-gradient-to-t from-ink via-ink/20 to-transparent" />
                <div className="absolute inset-x-0 bottom-0 p-5">
                  <h3 className="font-display text-2xl uppercase tracking-wide">{ind.name}</h3>
                  <p className="mt-2 text-xs text-haze line-clamp-2">{ind.description}</p>
                </div>
              </Link>
            </Reveal>
          ))}
        </div>
      </div>
    </section>
  );
}
