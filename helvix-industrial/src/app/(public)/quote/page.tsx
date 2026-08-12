import { PageHero } from "@/components/site/PageHero";
import { EnquiryForm } from "@/components/site/EnquiryForm";
import { buildMetadata } from "@/lib/seo";

export const metadata = buildMetadata({
  title: "Get a Quote",
  description: "Request a technical and commercial quotation for industrial fasteners from Helvix.",
  path: "/quote",
});

export default async function QuotePage({
  searchParams,
}: {
  searchParams: Promise<{ product?: string }>;
}) {
  const { product } = await searchParams;
  return (
    <>
      <PageHero
        eyebrow="Quotation"
        title="Get a Quote"
        subtitle="Send the standard, grade, quantity, destination and any drawing. We reply with availability and price."
        image="/images/hero/hero-fasteners.jpg"
      />
      <section className="surface-paper text-ink py-24">
        <div className="container-site max-w-3xl">
          <EnquiryForm type="quote" productName={product || ""} />
        </div>
      </section>
    </>
  );
}
