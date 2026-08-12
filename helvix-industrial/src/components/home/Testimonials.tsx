import { Reveal } from "@/components/site/Reveal";

export function Testimonials({
  items,
}: {
  items: {
    id: string;
    quote: string;
    name: string;
    company: string;
    designation: string;
  }[];
}) {
  return (
    <section className="bg-charcoal py-24">
      <div className="container-site">
        <Reveal>
          <p className="eyebrow">Voice of the buyer</p>
          <h2 className="display text-5xl mt-4">Testimonials</h2>
        </Reveal>
        <div className="mt-14 grid lg:grid-cols-3 gap-5">
          {items.map((t, i) => (
            <Reveal key={t.id} delay={i * 0.08}>
              <blockquote className="h-full border border-white/10 p-8">
                <p className="text-lg leading-relaxed text-paper">“{t.quote}”</p>
                <footer className="mt-8">
                  <p className="font-display tracking-wider uppercase">{t.name}</p>
                  <p className="text-sm text-mist">
                    {t.designation}, {t.company}
                  </p>
                </footer>
              </blockquote>
            </Reveal>
          ))}
        </div>
      </div>
    </section>
  );
}
