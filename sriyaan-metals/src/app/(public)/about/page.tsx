import { prisma } from "@/lib/prisma";
import { PageHero } from "@/components/site/PageHero";
import { buildMetadata } from "@/lib/seo";
import Link from "next/link";

export const metadata = buildMetadata({
  title: "About Us",
  description:
    "Company information and contact details for SRIYAAN METALS in Mumbai, Maharashtra, India.",
  path: "/about",
});

export default async function AboutPage() {
  const page = await prisma.pageContent.findUnique({ where: { slug: "about" } });
  return (
    <>
      <PageHero
        eyebrow="About SRIYAAN METALS"
        title={page?.title || "About Our Company"}
        subtitle={page?.subtitle}
        image={page?.image || "/images/about/plant.jpg"}
      />
      <section className="surface-paper text-ink py-24">
        <div className="container-site grid lg:grid-cols-12 gap-14">
          <div className="lg:col-span-7 space-y-5 text-lg leading-relaxed text-[#3d434c] whitespace-pre-line">
            {page?.body}
          </div>
          <aside className="lg:col-span-5 border-l border-black/10 pl-8 space-y-8">
            <div>
              <p className="eyebrow">Registered detail</p>
              <p className="font-display text-3xl uppercase tracking-wide mt-3">GST 27CRKPS0693G1ZB</p>
            </div>
            <div>
              <p className="eyebrow">Location</p>
              <p className="font-display text-3xl uppercase tracking-wide mt-3">Opera House, Mumbai</p>
            </div>
            <p className="text-sm text-[#68707b] leading-relaxed">
              Experience, capabilities, mission, vision and business milestones remain CMS fields until verified client content is supplied.
            </p>
          </aside>
        </div>
        <div className="container-site mt-20 grid md:grid-cols-3 gap-6">
          {[
            ["Product discovery", "Searchable categories, products and flexible technical specifications."],
            ["Business enquiries", "General, product and vendor requests stored in the admin dashboard."],
            ["Verified publishing", "Claims, certificates and references are published only from the CMS."],
          ].map(([title, description]) => (
            <article key={title} className="bg-white border border-black/8 p-8">
              <h2 className="font-display text-2xl uppercase tracking-wide">{title}</h2>
              <p className="mt-3 text-[#5a616c]">{description}</p>
            </article>
          ))}
        </div>
        <div className="container-site mt-14 flex flex-wrap gap-3">
          <Link href="/products" className="btn btn-dark">Explore Products</Link>
          <Link href="/quote" className="btn btn-primary">Get a Quote</Link>
        </div>
      </section>
    </>
  );
}
