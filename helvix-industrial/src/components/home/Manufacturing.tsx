import Link from "next/link";
import { ParallaxLayer, ParallaxRoot } from "@/components/site/Parallax";

export function Manufacturing({
  images,
}: {
  images: { id: string; title: string; caption: string; image: string }[];
}) {
  const bg = images[1]?.image || "/images/hero/hero-factory.jpg";
  const fg = images[0]?.image || "/images/factory/cnc-close.jpg";

  return (
    <ParallaxRoot className="relative min-h-[110vh] overflow-hidden bg-ink">
      <ParallaxLayer speed={0.18} className="absolute inset-[-20%]">
        <div
          className="absolute inset-0 bg-cover bg-center"
          style={{ backgroundImage: `url(${bg})` }}
        />
      </ParallaxLayer>
      <ParallaxLayer speed={0.2} className="absolute inset-0">
        <div className="absolute inset-0 bg-ink/70" />
      </ParallaxLayer>
      <ParallaxLayer
        speed={0.42}
        className="absolute right-[6%] top-[18%] w-[34%] max-w-md hidden lg:block"
      >
        <div className="aspect-[4/5] overflow-hidden border border-white/15">
          <img src={fg} alt="CNC machining" className="h-full w-full object-cover" />
        </div>
      </ParallaxLayer>

      <div className="relative z-10 container-site py-28">
        <p className="eyebrow">Infrastructure</p>
        <h2 className="display text-5xl md:text-7xl mt-4 max-w-3xl">
          Manufacturing that can take a drawing
        </h2>
        <p className="mt-6 max-w-xl text-haze text-lg">
          Forging, CNC, heat treatment, coating, inspection and export packing
          under one quality system — from raw bar to sealed container.
        </p>
        <div className="mt-14 grid sm:grid-cols-2 lg:grid-cols-3 gap-4 max-w-4xl">
          {images.slice(0, 6).map((img) => (
            <article key={img.id} className="border border-white/10 bg-ink/40 backdrop-blur-sm p-5">
              <p className="font-display tracking-wider uppercase text-brass">{img.title}</p>
              <p className="mt-2 text-sm text-mist">{img.caption}</p>
            </article>
          ))}
        </div>
        <Link href="/manufacturing" className="btn btn-primary mt-12">
          View Infrastructure
        </Link>
      </div>
    </ParallaxRoot>
  );
}
