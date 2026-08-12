import { prisma } from "@/lib/prisma";
import { PageHero } from "@/components/site/PageHero";
import { buildMetadata } from "@/lib/seo";
import Link from "next/link";

export const metadata = buildMetadata({
  title: "Industries We Serve",
  description:
    "Helvix supplies fasteners to construction, automotive, oil & gas, power, rail and heavy machinery.",
  path: "/industries",
});

export default async function IndustriesPage() {
  const industries = await prisma.industry.findMany({
    where: { published: true },
    orderBy: { sortOrder: "asc" },
  });
  return (
    <>
      <PageHero
        eyebrow="Markets"
        title="Industries We Serve"
        subtitle="Application knowledge across the sectors that consume industrial fasteners at scale."
        image="/images/industries/construction.jpg"
      />
      <section className="surface-paper text-ink py-24">
        <div className="container-site grid md:grid-cols-2 gap-6">
          {industries.map((ind) => (
            <Link key={ind.id} href={`/industries/${ind.slug}`} className="group grid md:grid-cols-5 bg-white border border-black/8 overflow-hidden">
              <div className="md:col-span-2 img-zoom min-h-44">
                <img src={ind.image} alt={ind.name} className="h-full w-full object-cover" />
              </div>
              <div className="md:col-span-3 p-7">
                <h2 className="font-display text-3xl uppercase tracking-wide">{ind.name}</h2>
                <p className="mt-3 text-[#5a616c]">{ind.description}</p>
                <p className="mt-4 text-xs tracking-[0.16em] uppercase text-brass-deep">
                  {ind.applications}
                </p>
              </div>
            </Link>
          ))}
        </div>
      </section>
    </>
  );
}
