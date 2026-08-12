import { ParallaxLayer, ParallaxRoot } from "@/components/site/Parallax";

export function PageHero({
  eyebrow,
  title,
  subtitle,
  image,
}: {
  eyebrow: string;
  title: string;
  subtitle?: string;
  image: string;
}) {
  return (
    <ParallaxRoot className="relative min-h-[58vh] overflow-hidden bg-ink">
      <ParallaxLayer speed={0.2} className="absolute inset-[-14%]">
        <div
          className="absolute inset-0 bg-cover bg-center"
          style={{ backgroundImage: `url(${image})` }}
        />
      </ParallaxLayer>
      <div className="absolute inset-0 bg-gradient-to-b from-ink/70 via-ink/55 to-ink" />
      <div className="relative z-10 container-site pt-40 pb-20">
        <p className="eyebrow">{eyebrow}</p>
        <h1 className="display text-5xl md:text-7xl mt-4 max-w-4xl">{title}</h1>
        {subtitle && <p className="mt-6 max-w-2xl text-lg text-haze">{subtitle}</p>}
      </div>
    </ParallaxRoot>
  );
}
