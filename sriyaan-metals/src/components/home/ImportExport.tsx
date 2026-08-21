import Link from "next/link";
import { Reveal } from "@/components/site/Reveal";

export function ImportExport({
  importBody,
  exportBody,
}: {
  importBody: string;
  exportBody: string;
}) {
  return (
    <section className="bg-charcoal py-24">
      <div className="container-site grid lg:grid-cols-2 gap-px bg-white/10">
        <Reveal className="bg-charcoal p-10 lg:p-14">
          <p className="eyebrow">Inbound</p>
          <h2 className="display text-5xl mt-4">Import</h2>
          <p className="mt-6 text-haze leading-relaxed">{importBody}</p>
          <ul className="mt-8 space-y-2 text-sm text-mist">
            {[
              "Product description",
              "Material and grade",
              "Required quantity",
              "Origin preference",
              "Delivery location",
            ].map((item) => (
              <li key={item} className="flex gap-3">
                <span className="text-brass">▸</span>
                {item}
              </li>
            ))}
          </ul>
        </Reveal>
        <Reveal delay={0.1} className="bg-charcoal p-10 lg:p-14">
          <p className="eyebrow">Outbound</p>
          <h2 className="display text-5xl mt-4">Export</h2>
          <p className="mt-6 text-haze leading-relaxed">{exportBody}</p>
          <ul className="mt-8 space-y-2 text-sm text-mist">
            {[
              "Destination country",
              "Product specification",
              "Required quantity",
              "Documentation needs",
              "Target delivery date",
              "Preferred delivery terms",
            ].map((item) => (
              <li key={item} className="flex gap-3">
                <span className="text-brass">▸</span>
                {item}
              </li>
            ))}
          </ul>
          <Link href="/contact?topic=export" className="btn btn-primary mt-10">
            Talk to Our Export Team
          </Link>
        </Reveal>
      </div>
    </section>
  );
}
