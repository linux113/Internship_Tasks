import Link from "next/link";
import { ParallaxLayer, ParallaxRoot } from "@/components/site/Parallax";
import { Reveal } from "@/components/site/Reveal";

export function AboutSplit({
  title,
  body,
  image,
  cta,
  ctaUrl,
}: {
  title: string;
  body: string;
  image: string;
  cta: string;
  ctaUrl: string;
}) {
  const paragraphs = body.split("\n").filter(Boolean);

  return (
    <ParallaxRoot className="relative bg-charcoal overflow-hidden">
      <div className="grid lg:grid-cols-2 min-h-[80vh]">
        <div className="relative min-h-[50vh] overflow-hidden">
          <ParallaxLayer speed={0.28} className="absolute inset-[-12%]">
            <div
              className="absolute inset-0 bg-cover bg-center"
              style={{ backgroundImage: `url(${image})` }}
            />
          </ParallaxLayer>
          <div className="absolute inset-0 bg-gradient-to-r from-transparent to-charcoal/40" />
        </div>
        <div className="relative z-10 flex items-center px-8 lg:px-16 py-20">
          <Reveal>
            <p className="eyebrow">The company</p>
            <h2 className="display text-5xl md:text-6xl mt-4">{title}</h2>
            <div className="mt-8 space-y-5 text-haze leading-relaxed max-w-xl">
              {paragraphs.map((p) => (
                <p key={p.slice(0, 24)}>{p}</p>
              ))}
            </div>
            <Link href={ctaUrl} className="btn btn-primary mt-10">
              {cta}
            </Link>
          </Reveal>
        </div>
      </div>
    </ParallaxRoot>
  );
}
