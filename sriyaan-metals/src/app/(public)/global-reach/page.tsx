import { prisma } from "@/lib/prisma";
import { PageHero } from "@/components/site/PageHero";
import { GlobalMap } from "@/components/home/GlobalMap";
import { buildMetadata } from "@/lib/seo";

export const metadata = buildMetadata({
  title: "Global Reach",
  description:
    "Discuss international product and destination requirements with SRIYAAN METALS.",
  path: "/global-reach",
});

export default async function GlobalReachPage() {
  const [page, countries] = await Promise.all([
    prisma.pageContent.findUnique({ where: { slug: "global-reach" } }),
    prisma.country.findMany({ where: { published: true }, orderBy: { sortOrder: "asc" } }),
  ]);
  return (
    <>
      <PageHero
        eyebrow="Markets"
        title={page?.title || "Global Reach. Local Commitment."}
        subtitle={page?.subtitle}
        image={page?.image || "/images/hero/hero-factory.jpg"}
      />
      <section className="surface-paper text-ink py-16">
        <p className="container-site max-w-3xl text-lg text-[#3d434c] whitespace-pre-line">
          {page?.body}
        </p>
      </section>
      <GlobalMap countries={countries} />
    </>
  );
}
