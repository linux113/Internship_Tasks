import { prisma } from "@/lib/prisma";
import { PageHero } from "@/components/site/PageHero";
import { ImportExport } from "@/components/home/ImportExport";
import { getHomepage } from "@/lib/cms";
import { buildMetadata } from "@/lib/seo";

export const metadata = buildMetadata({
  title: "Import & Export",
  description:
    "Global sourcing and export logistics for industrial fasteners from Helvix Industrial.",
  path: "/import-export",
});

export default async function ImportExportPage() {
  const [page, home] = await Promise.all([
    prisma.pageContent.findUnique({ where: { slug: "import-export" } }),
    getHomepage(),
  ]);
  return (
    <>
      <PageHero
        eyebrow="Trade"
        title={page?.title || "Import & Export"}
        subtitle={page?.subtitle}
        image="/images/hero/hero-factory.jpg"
      />
      <ImportExport importBody={home?.importBody || ""} exportBody={home?.exportBody || ""} />
    </>
  );
}
