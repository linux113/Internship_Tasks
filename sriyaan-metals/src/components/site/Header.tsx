"use client";

import Link from "next/link";
import { useEffect, useState } from "react";
import { Menu, X, MessageCircle } from "lucide-react";
import { whatsappLink } from "@/lib/utils";

const NAV = [
  { href: "/", label: "Home" },
  { href: "/products", label: "Products" },
  { href: "/about", label: "About Us" },
  { href: "/quality", label: "Quality" },
  { href: "/manufacturing", label: "Manufacturing" },
  { href: "/industries", label: "Industries" },
  { href: "/global-reach", label: "Global Reach" },
  { href: "/blog", label: "Blogs" },
  { href: "/vendor", label: "Be Our Vendor" },
  { href: "/contact", label: "Contact Us" },
];

export function Header({
  whatsapp = "+91 96195 61657",
}: {
  whatsapp?: string;
}) {
  const [solid, setSolid] = useState(false);
  const [open, setOpen] = useState(false);

  useEffect(() => {
    const onScroll = () => setSolid(window.scrollY > 24);
    onScroll();
    window.addEventListener("scroll", onScroll, { passive: true });
    return () => window.removeEventListener("scroll", onScroll);
  }, []);

  useEffect(() => {
    document.body.style.overflow = open ? "hidden" : "";
    return () => {
      document.body.style.overflow = "";
    };
  }, [open]);

  return (
    <header
      className={`fixed inset-x-0 top-0 z-50 transition-all duration-500 ${
        solid || open
          ? "bg-ink/92 backdrop-blur-md border-b border-white/8"
          : "bg-transparent"
      }`}
    >
      <div className="container-wide flex items-center justify-between gap-6 h-[78px]">
        <Link href="/" className="flex items-center gap-3 shrink-0" aria-label="SRIYAAN METALS home">
          <img src="/sriyaan-logo.jpeg" alt="" className="h-11 w-11 rounded-sm object-cover" />
          <span className="leading-none">
            <span className="block font-display tracking-[0.2em] text-[1rem] sm:text-[1.05rem]">
              SRIYAAN
            </span>
            <span className="block text-[0.58rem] tracking-[0.28em] text-mist uppercase mt-1">
              Metals
            </span>
          </span>
        </Link>

        <nav className="hidden xl:flex items-center gap-5 text-[0.72rem] tracking-[0.14em] uppercase text-haze">
          {NAV.slice(0, 8).map((item) => (
            <Link
              key={item.href}
              href={item.href}
              className="hover:text-brass transition-colors"
            >
              {item.label}
            </Link>
          ))}
        </nav>

        <div className="flex items-center gap-2 sm:gap-3">
          <a
            href={whatsappLink(
              whatsapp,
              "Hello SRIYAAN METALS, I would like to discuss a product requirement.",
            )}
            target="_blank"
            rel="noopener noreferrer"
            className="hidden sm:grid h-10 w-10 place-items-center border border-white/15 text-brass hover:border-brass transition-colors"
            aria-label="WhatsApp"
          >
            <MessageCircle size={18} />
          </a>
          <Link
            href="/admin"
            className="hidden md:inline-flex items-center h-10 px-3 border border-white/15 text-[0.68rem] tracking-[0.16em] uppercase hover:border-brass hover:text-brass"
          >
            Admin
          </Link>
          <Link href="/quote" className="btn btn-primary !min-h-10 !px-4 text-[0.7rem]">
            Get a Quote
          </Link>
          <button
            className="xl:hidden grid h-10 w-10 place-items-center border border-white/15"
            onClick={() => setOpen((v) => !v)}
            aria-label="Open menu"
          >
            {open ? <X size={18} /> : <Menu size={18} />}
          </button>
        </div>
      </div>

      {open && (
        <div className="xl:hidden bg-ink border-t border-white/8 h-[calc(100dvh-78px)] overflow-y-auto">
          <nav className="container-site py-8 flex flex-col gap-1">
            {NAV.map((item) => (
              <Link
                key={item.href}
                href={item.href}
                onClick={() => setOpen(false)}
                className="font-display uppercase tracking-[0.16em] text-2xl py-2 border-b border-white/8 hover:text-brass"
              >
                {item.label}
              </Link>
            ))}
            <Link
              href="/import-export"
              onClick={() => setOpen(false)}
              className="font-display uppercase tracking-[0.16em] text-2xl py-2 hover:text-brass"
            >
              Import & Export
            </Link>
            <Link
              href="/admin"
              onClick={() => setOpen(false)}
              className="font-display uppercase tracking-[0.16em] text-2xl py-2 text-brass"
            >
              Admin Dashboard
            </Link>
          </nav>
        </div>
      )}
    </header>
  );
}
