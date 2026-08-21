import { prisma } from "@/lib/prisma";
import { PageHero } from "@/components/site/PageHero";
import { Testimonials } from "@/components/home/Testimonials";
import { buildMetadata } from "@/lib/seo";

export const metadata = buildMetadata({
  title: "Customers & Testimonials",
  description: "Verified customer references and testimonials published by SRIYAAN METALS.",
  path: "/customers",
});

export default async function CustomersPage() {
  const [customers, testimonials] = await Promise.all([
    prisma.customer.findMany({ where: { published: true }, orderBy: { sortOrder: "asc" } }),
    prisma.testimonial.findMany({ where: { published: true }, orderBy: { sortOrder: "asc" } }),
  ]);
  return (
    <>
      <PageHero
        eyebrow="Relationships"
        title="Customers & Testimonials"
        subtitle="References appear only after they are supplied, approved and published by an administrator."
        image="/images/about/plant.jpg"
      />
      <section className="surface-paper text-ink py-24">
        <div className="container-site grid sm:grid-cols-2 lg:grid-cols-4 gap-4">
          {customers.map((customer) => (
            <a
              key={customer.id}
              href={customer.website || undefined}
              className="bg-white border border-black/8 h-32 grid place-items-center p-6"
            >
              <img src={customer.logo} alt={customer.name} className="max-h-12" />
            </a>
          ))}
          {customers.length === 0 && (
            <div className="sm:col-span-2 lg:col-span-4 bg-white border border-black/8 p-8">
              <p className="font-display text-2xl uppercase tracking-wide">No customer logos published</p>
              <p className="mt-2 text-[#5a616c]">No customer identity or endorsement has been invented for this website.</p>
            </div>
          )}
        </div>
      </section>
      {testimonials.length > 0 && <Testimonials items={testimonials} />}
    </>
  );
}
