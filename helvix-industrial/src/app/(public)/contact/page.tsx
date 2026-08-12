import { getSettings } from "@/lib/cms";
import { PageHero } from "@/components/site/PageHero";
import { EnquiryForm } from "@/components/site/EnquiryForm";
import { buildMetadata } from "@/lib/seo";

export const metadata = buildMetadata({
  title: "Contact Us",
  description: "Contact Helvix Industrial for quotes, technical support and export enquiries.",
  path: "/contact",
});

export default async function ContactPage() {
  const s = await getSettings();
  return (
    <>
      <PageHero
        eyebrow="Contact"
        title="Talk to the people who ship the parts"
        subtitle="Applications, documentation and a commercial reply — not a ticket queue."
        image="/images/about/plant.jpg"
      />
      <section className="surface-paper text-ink py-24">
        <div className="container-site grid lg:grid-cols-2 gap-16">
          <div className="space-y-6">
            <Info label="Office" value={s.officeAddress} />
            <Info label="Factory" value={s.factoryAddress} />
            <Info label="Phone" value={s.phone} />
            <Info label="Email" value={s.email} />
            <Info label="WhatsApp" value={s.whatsapp} />
            <Info label="Hours" value={s.hours} />
            {s.mapsEmbed && (
              <iframe
                title="Helvix location"
                src={s.mapsEmbed}
                className="w-full h-72 border-0 grayscale"
                loading="lazy"
              />
            )}
          </div>
          <EnquiryForm type="contact" />
        </div>
      </section>
    </>
  );
}

function Info({ label, value }: { label: string; value?: string }) {
  if (!value) return null;
  return (
    <div>
      <p className="text-[0.68rem] tracking-[0.2em] uppercase text-brass-deep">{label}</p>
      <p className="mt-1">{value}</p>
    </div>
  );
}
