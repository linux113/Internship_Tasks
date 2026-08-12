import { prisma } from "@/lib/prisma";
import { PageHero } from "@/components/site/PageHero";
import { ParallaxLayer, ParallaxRoot } from "@/components/site/Parallax";
import { buildMetadata } from "@/lib/seo";

export const metadata = buildMetadata({
  title: "Manufacturing & Infrastructure",
  description:
    "Explore Helvix manufacturing: CNC, forging, warehouse, inspection, packaging and dispatch.",
  path: "/manufacturing",
});

export default async function ManufacturingPage() {
  const [page, images] = await Promise.all([
    prisma.pageContent.findUnique({ where: { slug: "manufacturing" } }),
    prisma.infrastructureImage.findMany({
      where: { published: true },
      orderBy: { sortOrder: "asc" },
    }),
  ]);

  return (
    <>
      <PageHero
        eyebrow="Infrastructure"
        title={page?.title || "Manufacturing"}
        subtitle={page?.subtitle}
        image={page?.image || "/images/factory/cnc-close.jpg"}
      />
      <ParallaxRoot className="relative min-h-[70vh] overflow-hidden bg-ink">
        <ParallaxLayer speed={0.18} className="absolute inset-[-16%]">
          <div
            className="absolute inset-0 bg-cover bg-center"
            style={{ backgroundImage: "url(/images/hero/hero-factory.jpg)" }}
          />
        </ParallaxLayer>
        <div className="absolute inset-0 bg-ink/70" />
        <div className="relative z-10 container-site py-24 max-w-3xl">
          <p className="text-lg text-haze whitespace-pre-line">{page?.body}</p>
        </div>
      </ParallaxRoot>
      <section className="surface-paper text-ink py-24">
        <div className="container-site grid md:grid-cols-2 gap-6">
          {images.map((img) => (
            <article key={img.id} className="bg-white border border-black/8">
              <div className="img-zoom aspect-[16/10]">
                <img src={img.image} alt={img.title} className="h-full w-full object-cover" />
              </div>
              <div className="p-6">
                <h3 className="font-display text-2xl uppercase tracking-wide">{img.title}</h3>
                <p className="mt-2 text-[#5a616c]">{img.caption}</p>
              </div>
            </article>
          ))}
        </div>
      </section>
    </>
  );
}
