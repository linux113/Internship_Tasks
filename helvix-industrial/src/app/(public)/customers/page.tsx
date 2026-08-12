import { prisma } from "@/lib/prisma";
import { PageHero } from "@/components/site/PageHero";
import { Testimonials } from "@/components/home/Testimonials";
import { buildMetadata } from "@/lib/seo";

export const metadata = buildMetadata({
  title: "Our Customers",
  description: "Trusted by industry leaders across construction, energy, rail and OEM manufacturing.",
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
        title="Trusted By Industry Leaders"
        subtitle="Programme supply and project packages for manufacturers, EPCs and fabricators."
        image="/images/about/plant.jpg"
      />
      <section className="surface-paper text-ink py-24">
        <div className="container-site grid sm:grid-cols-2 lg:grid-cols-4 gap-4">
          {customers.map((c) => (
            <a
              key={c.id}
              href={c.website || "#"}
              className="bg-white border border-black/8 h-32 grid place-items-center p-6"
            >
              <img src={c.logo} alt={c.name} className="max-h-12" />
            </a>
          ))}
        </div>
      </section>
      <Testimonials items={testimonials} />
    </>
  );
}
