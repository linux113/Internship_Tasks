import { Reveal } from "@/components/site/Reveal";
import { Globe, Grid3x3, Scale, ShieldCheck, Clock3, Wrench } from "lucide-react";

const ICONS: Record<string, typeof ShieldCheck> = {
  shield: ShieldCheck,
  clock: Clock3,
  scale: Scale,
  grid: Grid3x3,
  globe: Globe,
  tool: Wrench,
};

export function WhyChoose({
  items,
}: {
  items: { id: string; title: string; description: string; icon: string }[];
}) {
  return (
    <section className="bg-ink py-24">
      <div className="container-site">
        <Reveal>
          <p className="eyebrow">Why Helvix</p>
          <h2 className="display text-5xl md:text-6xl mt-4">Why Choose Us</h2>
        </Reveal>
        <div className="mt-14 grid sm:grid-cols-2 lg:grid-cols-3 gap-px bg-white/8">
          {items.map((item, i) => {
            const Icon = ICONS[item.icon] || ShieldCheck;
            return (
              <Reveal key={item.id} delay={i * 0.05} className="bg-ink">
                <article className="h-full p-8 border border-transparent hover:border-brass/40 transition-colors">
                  <Icon className="text-brass" size={22} strokeWidth={1.4} />
                  <h3 className="mt-6 font-display text-2xl tracking-wide uppercase">
                    {item.title}
                  </h3>
                  <p className="mt-3 text-mist leading-relaxed">{item.description}</p>
                </article>
              </Reveal>
            );
          })}
        </div>
      </div>
    </section>
  );
}
