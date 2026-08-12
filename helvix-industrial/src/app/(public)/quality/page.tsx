import { prisma } from "@/lib/prisma";
import { PageHero } from "@/components/site/PageHero";
import { buildMetadata } from "@/lib/seo";
import Link from "next/link";

export const metadata = buildMetadata({
  title: "Quality & Certifications",
  description:
    "ISO certifications, material certificates, inspection reports and third-party inspection at Helvix Industrial.",
  path: "/quality",
});

export default async function QualityPage() {
  const [page, certs] = await Promise.all([
    prisma.pageContent.findUnique({ where: { slug: "quality" } }),
    prisma.certification.findMany({
      where: { published: true },
      orderBy: { sortOrder: "asc" },
    }),
  ]);

  return (
    <>
      <PageHero
        eyebrow="Quality system"
        title={page?.title || "Quality & Certifications"}
        subtitle={page?.subtitle}
        image={page?.image || "/images/factory/inspection.jpg"}
      />
      <section className="surface-paper text-ink py-24">
        <div className="container-site">
          <p className="max-w-3xl text-lg text-[#3d434c] whitespace-pre-line">{page?.body}</p>
          <div className="mt-14 grid md:grid-cols-2 lg:grid-cols-3 gap-5">
            {certs.map((c) => (
              <article key={c.id} className="bg-white border border-black/8 p-8">
                <img src={c.image} alt={c.name} className="h-20 w-20" />
                <h3 className="mt-6 font-display text-2xl uppercase tracking-wide">{c.name}</h3>
                <p className="text-xs tracking-[0.18em] uppercase text-brass-deep mt-2">{c.issuer}</p>
                <p className="mt-4 text-[#5a616c]">{c.description}</p>
              </article>
            ))}
          </div>
          <div className="mt-16 grid md:grid-cols-3 gap-6">
            {[
              ["Incoming inspection", "Material identity, certificates and dimensional spot checks."],
              ["In-process control", "Thread gauges, hardness and heat-treat records."],
              ["Final & TPI", "Open to TUV, BV, SGS or Lloyd's hold-points before packing."],
            ].map(([t, d]) => (
              <div key={t} className="border-t border-black/15 pt-5">
                <h3 className="font-display uppercase tracking-wide text-xl">{t}</h3>
                <p className="mt-2 text-[#5a616c]">{d}</p>
              </div>
            ))}
          </div>
          <Link href="/contact" className="btn btn-dark mt-12">Request certificates</Link>
        </div>
      </section>
    </>
  );
}
