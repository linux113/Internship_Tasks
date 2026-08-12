import Link from "next/link";
import { Reveal } from "@/components/site/Reveal";

export function QualityStrip({
  items,
}: {
  items: { id: string; name: string; issuer: string; image: string }[];
}) {
  return (
    <section className="surface-paper py-24">
      <div className="container-site">
        <Reveal>
          <div className="flex flex-col md:flex-row md:items-end md:justify-between gap-6">
            <div>
              <p className="eyebrow">Trust</p>
              <h2 className="display text-5xl md:text-6xl text-ink mt-4">
                Quality & Certifications
              </h2>
            </div>
            <Link href="/quality" className="btn btn-dark">
              View Certifications
            </Link>
          </div>
        </Reveal>
        <div className="mt-14 grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-4">
          {items.map((item, i) => (
            <Reveal key={item.id} delay={i * 0.04}>
              <article className="bg-white border border-black/8 p-5 text-center min-h-44 flex flex-col items-center justify-center">
                <img src={item.image} alt={item.name} className="h-16 w-16 object-contain" />
                <h3 className="mt-4 font-display tracking-wider uppercase text-ink text-sm">
                  {item.name}
                </h3>
                <p className="text-xs text-[#6b7280] mt-1">{item.issuer}</p>
              </article>
            </Reveal>
          ))}
        </div>
      </div>
    </section>
  );
}
