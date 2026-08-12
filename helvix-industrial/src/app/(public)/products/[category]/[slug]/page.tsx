import { prisma } from "@/lib/prisma";
import { getSettings } from "@/lib/cms";
import { buildMetadata, productJsonLd, breadcrumbJsonLd } from "@/lib/seo";
import { JsonLd } from "@/components/site/JsonLd";
import { EnquiryForm } from "@/components/site/EnquiryForm";
import { whatsappLink, splitLines } from "@/lib/utils";
import { notFound } from "next/navigation";
import Link from "next/link";

export async function generateMetadata({
  params,
}: {
  params: Promise<{ category: string; slug: string }>;
}) {
  const { slug } = await params;
  const product = await prisma.product.findUnique({
    where: { slug },
    include: { images: true },
  });
  if (!product) return {};
  return buildMetadata({
    title: product.seoTitle || product.name,
    description: product.seoDesc || product.shortDesc,
    path: `/products/${product ? (await prisma.category.findUnique({ where: { id: product.categoryId } }))?.slug : ""}/${product.slug}`,
    image: product.images[0]?.url,
    keywords: product.seoKeywords,
  });
}

export default async function ProductDetail({
  params,
}: {
  params: Promise<{ category: string; slug: string }>;
}) {
  const { slug, category } = await params;
  const [product, settings] = await Promise.all([
    prisma.product.findUnique({
      where: { slug },
      include: {
        category: true,
        subcategory: true,
        images: { orderBy: { sortOrder: "asc" } },
        documents: true,
      },
    }),
    getSettings(),
  ]);
  if (!product || product.category.slug !== category) notFound();

  const specs = [
    ["Material", product.material],
    ["Grade", product.grade],
    ["Size", product.size],
    ["Diameter", product.diameter],
    ["Length", product.length],
    ["Standard", product.standard],
    ["Finish", product.finish],
    ["Thread Type", product.threadType],
    ["Head Type", product.headType],
    ["Application", product.application],
    ["Availability", product.availability],
    ["SKU", product.sku],
  ];

  const wa = whatsappLink(
    settings.whatsapp || "919876543210",
    `Hello, I am interested in ${product.name}. Please share specifications, pricing and availability.`,
  );

  return (
    <article className="pt-28 surface-paper text-ink">
      <JsonLd
        data={productJsonLd({
          name: product.name,
          description: product.description,
          sku: product.sku,
          image: product.images[0]?.url,
          material: product.material,
        })}
      />
      <JsonLd
        data={breadcrumbJsonLd([
          { name: "Home", path: "/" },
          { name: "Products", path: "/products" },
          { name: product.category.name, path: `/products/${product.category.slug}` },
          { name: product.name, path: `/products/${product.category.slug}/${product.slug}` },
        ])}
      />
      <div className="container-site py-12 grid lg:grid-cols-2 gap-12">
        <div>
          <div className="aspect-square bg-sand overflow-hidden">
            {product.images[0] && (
              <img
                src={product.images[0].url}
                alt={product.images[0].alt || product.name}
                className="h-full w-full object-cover"
              />
            )}
          </div>
          {product.images.length > 1 && (
            <div className="mt-3 grid grid-cols-4 gap-2">
              {product.images.map((img) => (
                <img key={img.id} src={img.url} alt={img.alt} className="aspect-square object-cover" />
              ))}
            </div>
          )}
        </div>
        <div>
          <p className="text-[0.7rem] tracking-[0.2em] uppercase text-brass-deep">
            {product.category.name}
            {product.subcategory ? ` · ${product.subcategory.name}` : ""}
          </p>
          <h1 className="display text-5xl mt-3">{product.name}</h1>
          <p className="mt-5 text-lg text-[#3d434c]">{product.shortDesc}</p>
          <p className="mt-4 text-[#5a616c]">{product.description}</p>
          <div className="mt-8 flex flex-wrap gap-3">
            <Link href="#enquire" className="btn btn-primary">
              Send Enquiry
            </Link>
            <a href={wa} target="_blank" rel="noreferrer" className="btn btn-dark">
              Enquire on WhatsApp
            </a>
          </div>
        </div>
      </div>

      <div className="container-site pb-10">
        <h2 className="display text-3xl">Specifications</h2>
        <table className="mt-6 w-full max-w-3xl text-sm">
          <tbody>
            {specs.map(([k, v]) => (
              <tr key={k} className="border-b border-black/8">
                <th className="py-3 pr-6 text-left font-display tracking-wider uppercase text-xs w-48">
                  {k}
                </th>
                <td className="py-3">{v}</td>
              </tr>
            ))}
          </tbody>
        </table>
        {product.features && (
          <ul className="mt-8 space-y-2">
            {splitLines(product.features).map((f) => (
              <li key={f} className="flex gap-3">
                <span className="text-brass-deep">▸</span>
                {f}
              </li>
            ))}
          </ul>
        )}
        {product.documents.length > 0 && (
          <div className="mt-10">
            <h3 className="font-display uppercase tracking-wide text-xl">Documents</h3>
            <ul className="mt-3 space-y-2">
              {product.documents.map((d) => (
                <li key={d.id}>
                  <a href={d.url} className="link-underline">
                    {d.name}
                  </a>
                </li>
              ))}
            </ul>
          </div>
        )}
      </div>

      <section id="enquire" className="bg-sand py-16">
        <div className="container-site max-w-3xl">
          <h2 className="display text-4xl">Enquire about this product</h2>
          <div className="mt-8">
            <EnquiryForm type="product" productName={product.name} productId={product.id} />
          </div>
        </div>
      </section>
    </article>
  );
}
