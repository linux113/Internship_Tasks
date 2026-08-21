import Link from "next/link";
import { prisma } from "@/lib/prisma";

export async function Footer() {
  const [settingsRows, categories] = await Promise.all([
    prisma.setting.findMany(),
    prisma.category.findMany({
      where: { published: true },
      orderBy: { sortOrder: "asc" },
      take: 6,
    }),
  ]);
  const s = Object.fromEntries(settingsRows.map((r) => [r.key, r.value]));

  return (
    <footer className="bg-ink text-paper border-t border-white/8">
      <div className="container-site py-16 grid gap-12 md:grid-cols-2 lg:grid-cols-5">
        <div className="lg:col-span-2">
          <div className="flex items-center gap-3">
            <img src="/sriyaan-logo.jpeg" alt="" className="h-11 w-11 rounded-sm object-cover" />
            <span className="font-display tracking-[0.22em] text-xl">SRIYAAN METALS</span>
          </div>
          <p className="mt-5 max-w-sm text-mist leading-relaxed">
            B2B product discovery, specification sharing and direct commercial enquiries from Mumbai, India.
          </p>
          <div className="mt-6 flex gap-4 text-[0.72rem] tracking-[0.18em] uppercase text-brass">
            {s.linkedin && (
              <a href={s.linkedin} target="_blank" rel="noreferrer">
                LinkedIn
              </a>
            )}
            {s.instagram && (
              <a href={s.instagram} target="_blank" rel="noreferrer">
                Instagram
              </a>
            )}
            {s.facebook && (
              <a href={s.facebook} target="_blank" rel="noreferrer">
                Facebook
              </a>
            )}
            {s.youtube && (
              <a href={s.youtube} target="_blank" rel="noreferrer">
                YouTube
              </a>
            )}
          </div>
        </div>

        <div>
          <h3 className="font-display tracking-[0.2em] text-sm text-brass">Company</h3>
          <ul className="mt-4 space-y-2 text-haze">
            <li><Link href="/about">About Us</Link></li>
            <li><Link href="/quality">Quality</Link></li>
            <li><Link href="/manufacturing">Infrastructure</Link></li>
            <li><Link href="/global-reach">Global Reach</Link></li>
          </ul>
        </div>
        <div>
          <h3 className="font-display tracking-[0.2em] text-sm text-brass">Products</h3>
          <ul className="mt-4 space-y-2 text-haze">
            {categories.map((c) => (
              <li key={c.id}>
                <Link href={`/products/${c.slug}`}>{c.name}</Link>
              </li>
            ))}
            <li><Link href="/products">Product Catalogue</Link></li>
          </ul>
        </div>
        <div>
          <h3 className="font-display tracking-[0.2em] text-sm text-brass">Business</h3>
          <ul className="mt-4 space-y-2 text-haze">
            <li><Link href="/blog">Blog</Link></li>
            <li><Link href="/quality">Certifications</Link></li>
            <li><Link href="/vendor">Be Our Vendor</Link></li>
            <li><Link href="/quote">Get a Quote</Link></li>
            <li><Link href="/contact">Contact Us</Link></li>
          </ul>
          <div className="mt-6 text-sm text-mist space-y-1">
            <p>{s.phone}</p>
            <p>{s.email}</p>
            <p>WhatsApp {s.whatsapp}</p>
          </div>
        </div>
      </div>
      <div className="border-t border-white/8">
        <div className="container-site py-5 flex flex-col sm:flex-row gap-3 sm:items-center sm:justify-between text-xs text-mist tracking-wide">
          <p>© {new Date().getFullYear()} {s.legalName || "SRIYAAN METALS"}</p>
          <div className="flex gap-5">
            <Link href="/privacy">Privacy Policy</Link>
            <Link href="/terms">Terms & Conditions</Link>
            <Link href="/sitemap.xml">Sitemap</Link>
          </div>
        </div>
      </div>
    </footer>
  );
}
