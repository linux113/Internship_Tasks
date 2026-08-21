"use client";

import Link from "next/link";
import { useEffect, useState } from "react";
import { Menu, MessageCircle, Nut, X } from "lucide-react";
import { company, nav } from "@/lib/site-data";

export function Header() {
  const [open, setOpen] = useState(false);
  const [solid, setSolid] = useState(false);
  useEffect(() => {
    const onScroll = () => setSolid(scrollY > 18);
    onScroll(); addEventListener("scroll", onScroll, { passive: true });
    return () => removeEventListener("scroll", onScroll);
  }, []);
  useEffect(() => { document.body.style.overflow = open ? "hidden" : ""; return () => { document.body.style.overflow = ""; }; }, [open]);

  return <header className={`fixed inset-x-0 top-0 z-50 transition-all duration-300 ${solid || open ? "border-b border-white/10 bg-ink/92 backdrop-blur-xl" : "bg-gradient-to-b from-ink/80 to-transparent"}`}>
    <div className="container-wide flex h-[76px] items-center justify-between gap-4">
      <Link href="/" className="flex items-center gap-3" aria-label="Sriyaan Metals home">
        <span className="grid h-11 w-11 place-items-center border border-teal/70 bg-teal/10 text-teal"><Nut size={25} strokeWidth={1.4} /></span>
        <span><strong className="block font-display text-[1.05rem] tracking-[.18em]">SRIYAAN</strong><span className="block text-[.6rem] font-bold tracking-[.34em] text-muted">METALS</span></span>
      </Link>
      <nav className="hidden items-center gap-5 xl:flex" aria-label="Main navigation">
        {nav.map(([label, href]) => <Link key={href} href={href} className="text-[.67rem] font-bold uppercase tracking-[.12em] text-fog/80 transition-colors hover:text-teal">{label}</Link>)}
      </nav>
      <div className="flex items-center gap-2">
        <a className="hidden h-10 w-10 place-items-center border border-white/15 text-teal transition-colors hover:border-teal sm:grid" href={`https://wa.me/${company.whatsapp}`} target="_blank" rel="noreferrer" aria-label="Chat on WhatsApp"><MessageCircle size={18} /></a>
        <Link className="btn btn-primary !min-h-10 !px-4" href="/quote">Get a quote</Link>
        <button onClick={() => setOpen(v => !v)} className="grid h-10 w-10 place-items-center border border-white/15 xl:hidden" aria-expanded={open} aria-label="Toggle navigation">{open ? <X size={19} /> : <Menu size={19} />}</button>
      </div>
    </div>
    {open && <nav className="h-[calc(100dvh-76px)] overflow-y-auto border-t border-white/10 bg-ink px-5 py-7 xl:hidden">
      {nav.map(([label, href]) => <Link onClick={() => setOpen(false)} key={href} href={href} className="block border-b border-white/8 py-4 font-display text-2xl font-semibold uppercase tracking-tight">{label}</Link>)}
      <Link onClick={() => setOpen(false)} href="/vendor" className="block border-b border-white/8 py-4 font-display text-2xl font-semibold uppercase tracking-tight">Be our vendor</Link>
      <Link onClick={() => setOpen(false)} href="/admin" className="block py-4 text-sm font-bold uppercase tracking-widest text-teal">Admin portal</Link>
    </nav>}
  </header>;
}
