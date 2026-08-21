import { PageHero } from "@/components/site/PageHero";
import { buildMetadata } from "@/lib/seo";
import { VendorForm } from "@/components/site/VendorForm";

export const metadata = buildMetadata({
  title: "Become Our Vendor",
  description:
    "We are looking to build long-term relationships with reliable manufacturers and suppliers.",
  path: "/vendor",
});

export default function VendorPage() {
  return (
    <>
      <PageHero
        eyebrow="Supply partners"
        title="Become Our Vendor"
        subtitle="We are looking to build long-term relationships with reliable manufacturers and suppliers."
        image="/images/factory/warehouse.jpg"
      />
      <section className="surface-paper text-ink py-24">
        <div className="container-site grid lg:grid-cols-12 gap-14">
          <div className="lg:col-span-5">
            <h2 className="display text-4xl">What we look for</h2>
            <ul className="mt-6 space-y-3 text-[#3d434c]">
              {[
                "Process capability and repeatable quality",
                "Material traceability and certificates",
                "Capacity for programme and project volumes",
                "Willingness to accept inspection and audits",
              ].map((item) => (
                <li key={item} className="flex gap-3">
                  <span className="text-brass-deep">▸</span>
                  {item}
                </li>
              ))}
            </ul>
          </div>
          <div className="lg:col-span-7">
            <VendorForm />
          </div>
        </div>
      </section>
    </>
  );
}
