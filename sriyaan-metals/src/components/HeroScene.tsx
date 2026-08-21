"use client";

import Image from "next/image";
import Link from "next/link";
import { useEffect, useRef } from "react";
import { ArrowDown, ArrowUpRight, CircleCheck, Gauge, ScanLine } from "lucide-react";
import gsap from "gsap";
import { company } from "@/lib/site-data";

export function HeroScene() {
  const root = useRef<HTMLElement>(null);
  const visual = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const node = root.current;
    if (!node || matchMedia("(prefers-reduced-motion: reduce)").matches) return;
    const ctx = gsap.context(() => {
      const tl = gsap.timeline({ defaults: { ease: "power4.out" } });
      tl.from("[data-hero-line]", { yPercent: 110, duration: 1.15, stagger: .11 })
        .from("[data-hero-fade]", { y: 22, opacity: 0, duration: .75, stagger: .08 }, "-=.65")
        .from("[data-hero-visual]", { clipPath: "inset(12% 12% 12% 12%)", scale: 1.08, opacity: 0, duration: 1.25 }, "-=1");
    }, node);
    const finePointer = matchMedia("(pointer:fine)").matches;
    const move = (event: PointerEvent) => {
      if (!finePointer || !visual.current) return;
      const x = (event.clientX / innerWidth - .5) * 16;
      const y = (event.clientY / innerHeight - .5) * 12;
      gsap.to(visual.current, { x, y, duration: 1.2, ease: "power3.out" });
    };
    addEventListener("pointermove", move, { passive: true });
    return () => { ctx.revert(); removeEventListener("pointermove", move); };
  }, []);

  return <section ref={root} className="hero-shell technical-grid relative min-h-[100svh] overflow-hidden bg-ink">
    <div className="hero-aurora absolute inset-0" aria-hidden />
    <div className="absolute inset-x-0 top-0 z-10 h-40 bg-gradient-to-b from-ink to-transparent" />
    <div className="container-wide relative z-10 grid min-h-[100svh] items-end gap-10 pb-10 pt-32 lg:grid-cols-[1.06fr_.94fr] lg:items-center lg:pb-12">
      <div className="relative z-20 lg:pl-[max(0px,calc((100vw-1440px)/2))]">
        <div data-hero-fade className="flex items-center gap-3 text-[.65rem] font-bold uppercase tracking-[.24em] text-muted"><span className="h-px w-10 bg-teal"/> Mumbai · India <span className="text-white/30">/</span> Industrial supply</div>
        <h1 className="display mt-7 text-[clamp(3.9rem,8.4vw,8.4rem)] uppercase">
          <span className="block overflow-hidden"><span data-hero-line className="block">Precision</span></span>
          <span className="block overflow-hidden"><span data-hero-line className="block text-metallic">that holds</span></span>
          <span className="block overflow-hidden"><span data-hero-line className="block">industry.</span></span>
        </h1>
        <p data-hero-fade className="mt-7 max-w-xl text-base leading-8 text-fog/72 sm:text-lg">Standard and special fasteners sourced, verified and supplied for projects where consistency is non-negotiable.</p>
        <div data-hero-fade className="mt-9 flex flex-wrap gap-3"><Link href="/quote" className="btn btn-primary">Start an RFQ <ArrowUpRight size={16}/></Link><Link href="/products" className="btn btn-secondary">Explore the range</Link></div>
        <div data-hero-fade className="mt-12 grid max-w-2xl grid-cols-3 border-y border-white/10 py-5">
          {["ISO · DIN · ASTM","Standard + Special","India → Global"].map((item,i)=><div key={item} className={`px-3 first:pl-0 ${i?"border-l border-white/10":""}`}><p className="text-[.58rem] uppercase tracking-[.18em] text-muted">0{i+1}</p><p className="mt-2 font-display text-xs font-bold uppercase tracking-wide sm:text-sm">{item}</p></div>)}
        </div>
      </div>

      <div data-hero-visual ref={visual} className="relative min-h-[46vh] overflow-hidden border border-white/12 lg:min-h-[74vh]" style={{clipPath:"inset(0% 0% 0% 0%)"}}>
        <Image src="/images/hero-fasteners.jpg" alt="Precision industrial fasteners" fill priority sizes="(max-width:1024px) 100vw,50vw" className="object-cover" />
        <div className="absolute inset-0 bg-gradient-to-t from-ink/90 via-transparent to-ink/25"/>
        <div className="absolute inset-0 ring-1 ring-inset ring-white/10"/>
        <div className="scan-beam absolute inset-x-0 top-0 h-px bg-teal shadow-[0_0_28px_5px_rgba(202,166,106,.45)]" aria-hidden/>
        <div className="glass absolute right-4 top-4 flex items-center gap-3 px-4 py-3 text-xs sm:right-6 sm:top-6"><ScanLine className="text-teal" size={17}/><span><b className="block font-display uppercase tracking-wider">Specification-led</b><span className="text-muted">Supply control</span></span></div>
        <div className="absolute bottom-5 left-5 right-5 grid gap-3 sm:grid-cols-2">
          <div className="glass p-4"><div className="flex items-center gap-2 text-teal"><Gauge size={16}/><span className="text-[.62rem] font-bold uppercase tracking-[.18em]">Technical range</span></div><p className="mt-3 font-display text-xl font-bold uppercase">M3 → M72</p></div>
          <div className="glass p-4"><div className="flex items-center gap-2 text-teal"><CircleCheck size={16}/><span className="text-[.62rem] font-bold uppercase tracking-[.18em]">Business desk</span></div><a href={`tel:${company.phones[0].replace(/\s/g,"")}`} className="mt-3 block font-display text-xl font-bold uppercase">{company.phones[0]}</a></div>
        </div>
      </div>
    </div>
    <a href="#catalogue" aria-label="Scroll to catalogue" className="absolute bottom-5 left-1/2 z-20 hidden -translate-x-1/2 items-center gap-2 text-[.58rem] font-bold uppercase tracking-[.2em] text-muted xl:flex">Scroll <ArrowDown className="animate-bounce" size={14}/></a>
  </section>;
}
