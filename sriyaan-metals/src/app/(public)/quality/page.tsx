import { prisma } from "@/lib/prisma";
import { PageHero } from "@/components/site/PageHero";
import { buildMetadata } from "@/lib/seo";
import Link from "next/link";

export const metadata = buildMetadata({
  title: "Quality & Certifications",
  description:
    "Verified quality and certification information published by SRIYAAN METALS.",
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
          {certs.length === 0 && (
            <div className="mt-12 border border-black/10 bg-white p-8">
              <h2 className="font-display uppercase tracking-wide text-2xl">No certificates published</h2>
              <p className="mt-2 text-[#5a616c]">This page intentionally remains empty until verified certificate records are added in the admin panel.</p>
            </div>
          )}
          <Link href="/contact" className="btn btn-dark mt-12">Request certificates</Link>
        </div>
      </section>
    </>
  );
}
