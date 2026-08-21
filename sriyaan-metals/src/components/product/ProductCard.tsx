import Link from "next/link";

export function ProductCard({
  product,
}: {
  product: {
    name: string;
    slug: string;
    shortDesc: string;
    material: string;
    grade: string;
    size: string;
    application: string;
    category: { name: string; slug: string };
    images: { url: string; alt: string }[];
  };
}) {
  const image = product.images[0];
  return (
    <article className="group bg-white border border-black/8 flex flex-col card-hover">
      <Link href={`/products/${product.category.slug}/${product.slug}`} className="img-zoom aspect-[4/3] block">
        {image && (
          <img
            src={image.url}
            alt={image.alt || product.name}
            className="h-full w-full object-cover"
          />
        )}
      </Link>
      <div className="p-5 flex-1 flex flex-col">
        <p className="text-[0.68rem] tracking-[0.2em] uppercase text-brass-deep">
          {product.category.name}
        </p>
        <h3 className="mt-2 font-display text-2xl uppercase tracking-wide text-ink">
          <Link href={`/products/${product.category.slug}/${product.slug}`}>
            {product.name}
          </Link>
        </h3>
        <p className="mt-2 text-sm text-[#5a616c] line-clamp-2">{product.shortDesc}</p>
        <dl className="mt-4 grid grid-cols-2 gap-2 text-xs text-[#5a616c]">
          <div>
            <dt className="uppercase tracking-wider text-[0.62rem]">Material</dt>
            <dd className="text-ink">{product.material}</dd>
          </div>
          <div>
            <dt className="uppercase tracking-wider text-[0.62rem]">Grade</dt>
            <dd className="text-ink">{product.grade}</dd>
          </div>
          <div>
            <dt className="uppercase tracking-wider text-[0.62rem]">Size</dt>
            <dd className="text-ink">{product.size}</dd>
          </div>
          <div>
            <dt className="uppercase tracking-wider text-[0.62rem]">Application</dt>
            <dd className="text-ink line-clamp-1">{product.application}</dd>
          </div>
        </dl>
        <div className="mt-5 flex gap-2">
          <Link
            href={`/products/${product.category.slug}/${product.slug}`}
            className="btn btn-dark !min-h-10 !px-3 text-[0.65rem]"
          >
            View Product
          </Link>
          <Link
            href={`/quote?product=${encodeURIComponent(product.name)}`}
            className="btn btn-ghost !min-h-10 !px-3 text-[0.65rem] !text-ink !border-black/20"
          >
            Send Enquiry
          </Link>
        </div>
      </div>
    </article>
  );
}
