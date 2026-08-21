import Link from "next/link";
import { Mail, MapPin, Nut, Phone } from "lucide-react";
import { categories, company, nav } from "@/lib/site-data";

export function Footer() {
  return <footer className="border-t border-white/10 bg-[#040b0f]">
    <div className="container-site grid gap-12 py-16 md:grid-cols-2 lg:grid-cols-4">
      <div><div className="flex items-center gap-3"><span className="grid h-10 w-10 place-items-center border border-teal text-teal"><Nut /></span><span className="font-display font-bold tracking-[.18em]">SRIYAAN METALS</span></div><p className="mt-5 max-w-sm text-sm leading-7 text-muted">Industrial fasteners for construction, engineering, automotive, infrastructure and global supply requirements.</p><p className="mt-5 text-xs uppercase tracking-widest text-teal">GST · {company.gst}</p></div>
      <div><h3 className="text-xs font-bold uppercase tracking-[.2em] text-teal">Navigate</h3><ul className="mt-5 grid gap-2 text-sm text-fog/75">{nav.slice(0,6).map(([l,h]) => <li key={h}><Link className="hover:text-white" href={h}>{l}</Link></li>)}</ul></div>
      <div><h3 className="text-xs font-bold uppercase tracking-[.2em] text-teal">Product range</h3><ul className="mt-5 grid gap-2 text-sm text-fog/75">{categories.slice(0,6).map(c => <li key={c.slug}><Link className="hover:text-white" href={`/products?category=${c.slug}`}>{c.name}</Link></li>)}</ul></div>
      <div><h3 className="text-xs font-bold uppercase tracking-[.2em] text-teal">Contact</h3><ul className="mt-5 space-y-4 text-sm leading-6 text-fog/75"><li className="flex gap-3"><Phone className="mt-1 shrink-0 text-orange" size={16}/><span>{company.phones.join(" / ")}</span></li><li className="flex gap-3"><Mail className="mt-1 shrink-0 text-orange" size={16}/><a href={`mailto:${company.email}`}>{company.email}</a></li><li className="flex gap-3"><MapPin className="mt-1 shrink-0 text-orange" size={16}/><span>{company.address}</span></li></ul></div>
    </div>
    <div className="border-t border-white/8"><div className="container-site flex flex-col gap-3 py-5 text-xs text-muted sm:flex-row sm:items-center sm:justify-between"><p>© {new Date().getFullYear()} SRIYAAN METALS. All rights reserved.</p><div className="flex gap-5"><Link href="/privacy">Privacy</Link><Link href="/terms">Terms</Link><Link href="/sitemap.xml">Sitemap</Link></div></div></div>
  </footer>;
}
