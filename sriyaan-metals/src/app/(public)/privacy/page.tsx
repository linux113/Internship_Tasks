import { PageHero } from "@/components/site/PageHero";
import { buildMetadata } from "@/lib/seo";

export const metadata = buildMetadata({
  title: "Privacy Policy",
  description: "How SRIYAAN METALS handles enquiry and website data.",
  path: "/privacy",
});

export default function PrivacyPage() {
  return (
    <>
      <PageHero eyebrow="Legal" title="Privacy Policy" image="/images/hero/hero-factory.jpg" />
      <section className="surface-paper text-ink py-20">
        <div className="container-site max-w-3xl space-y-4 leading-relaxed text-[#3d434c]">
          <p>
            SRIYAAN METALS collects only the information you submit through enquiry, quote and
            vendor forms — typically name, company, contact details and requirement data. We use
            it to respond to your request and to administer orders.
          </p>
          <p>
            We do not sell personal data. Access is limited to authorised SRIYAAN METALS staff. Files you
            upload are stored securely and retained only as long as the commercial discussion
            requires, unless a longer statutory period applies.
          </p>
          <p>
            The site may use privacy-respecting analytics when configured by the administrator.
            You may request correction or deletion of your enquiry data by writing to
            info@sriyaanmetals.co.
          </p>
        </div>
      </section>
    </>
  );
}
