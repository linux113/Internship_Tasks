import { PageHero } from "@/components/site/PageHero";
import { buildMetadata } from "@/lib/seo";

export const metadata = buildMetadata({
  title: "Terms & Conditions",
  description: "Terms of use for the Helvix Industrial website.",
  path: "/terms",
});

export default function TermsPage() {
  return (
    <>
      <PageHero eyebrow="Legal" title="Terms & Conditions" image="/images/hero/hero-factory.jpg" />
      <section className="surface-paper text-ink py-20">
        <div className="container-site max-w-3xl space-y-4 leading-relaxed text-[#3d434c]">
          <p>
            Content on this website is provided for information. Product availability, standards
            and commercial terms are confirmed only in a written quotation or order acknowledgement
            issued by Helvix Industrial Fasteners Pvt. Ltd.
          </p>
          <p>
            All trademarks remain the property of their owners. Catalogue images are representative.
            Specifications must be checked against the applicable standard and the purchase order.
          </p>
        </div>
      </section>
    </>
  );
}
