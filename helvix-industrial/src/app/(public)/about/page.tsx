import { prisma } from "@/lib/prisma";
import { PageHero } from "@/components/site/PageHero";
import { buildMetadata } from "@/lib/seo";
import Link from "next/link";

export const metadata = buildMetadata({
  title: "About Us",
  description:
    "Helvix Industrial manufactures and exports precision fasteners from Sanand, India to more than forty countries.",
  path: "/about",
});

export default async function AboutPage() {
  const page = await prisma.pageContent.findUnique({ where: { slug: "about" } });
  return (
    <>
      <PageHero
        eyebrow="About Helvix"
        title={page?.title || "About Our Company"}
        subtitle={page?.subtitle}
        image={page?.image || "/images/about/plant.jpg"}
      />
      <section className="surface-paper text-ink py-24">
        <div className="container-site grid lg:grid-cols-12 gap-14">
          <div className="lg:col-span-7 space-y-5 text-lg leading-relaxed text-[#3d434c] whitespace-pre-line">
            {page?.body}
          </div>
          <aside className="lg:col-span-5 space-y-6">
            {[
              ["28+", "Years of supply"],
              ["40+", "Export markets"],
              ["12,000+", "Active SKUs"],
              ["ISO 9001", "Quality system"],
            ].map(([n, l]) => (
              <div key={l} className="border-t border-black/10 pt-4">
                <p className="display text-5xl">{n}</p>
                <p className="mt-1 tracking-[0.18em] uppercase text-xs text-[#6b7280]">{l}</p>
              </div>
            ))}
          </aside>
        </div>
        <div className="container-site mt-20 grid md:grid-cols-3 gap-6">
          {[
            ["Manufacturing & sourcing", "In-house process plus a qualified global vendor base."],
            ["Domestic & international", "Project supply in India and export programmes worldwide."],
            ["Customer-focused desk", "Applications, documentation and logistics in one team."],
          ].map(([t, d]) => (
            <article key={t} className="bg-white border border-black/8 p-8">
              <h3 className="font-display text-2xl uppercase tracking-wide">{t}</h3>
              <p className="mt-3 text-[#5a616c]">{d}</p>
            </article>
          ))}
        </div>
        <div className="container-site mt-14 flex gap-3">
          <Link href="/manufacturing" className="btn btn-dark">Infrastructure</Link>
          <Link href="/quote" className="btn btn-primary">Get a Quote</Link>
        </div>
      </section>
    </>
  );
}
