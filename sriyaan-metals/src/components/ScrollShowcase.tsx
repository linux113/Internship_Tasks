"use client";

import Image from "next/image";
import Link from "next/link";
import { motion, useScroll, useTransform } from "motion/react";
import { useRef } from "react";
import { ArrowUpRight, Box, FileCheck2, ScanSearch, Send } from "lucide-react";

const STEPS = [
  { icon: Send, number: "01", title: "Define", text: "Standard, material, grade, finish, dimensions and quantity." },
  { icon: ScanSearch, number: "02", title: "Source", text: "Select the right supply route for complexity, volume and lead time." },
  { icon: FileCheck2, number: "03", title: "Verify", text: "Align inspection, traceability and documentation with the order." },
  { icon: Box, number: "04", title: "Deliver", text: "Pack, document and coordinate dispatch for the agreed destination." },
];

export function ScrollShowcase(){
  const root=useRef<HTMLElement>(null);
  const {scrollYProgress}=useScroll({target:root,offset:["start end","end start"]});
  const rotateX=useTransform(scrollYProgress,[.05,.42,.85],[14,0,-4]);
  const scale=useTransform(scrollYProgress,[.05,.42,.85],[.82,1,.95]);
  const y=useTransform(scrollYProgress,[0,1],[80,-60]);
  return <section ref={root} className="relative overflow-hidden bg-[#050c10] py-28 lg:py-36">
    <div className="absolute inset-0 technical-grid opacity-40"/>
    <div className="container-site relative">
      <div className="mx-auto max-w-4xl text-center"><p className="eyebrow justify-center before:hidden">The controlled route</p><h2 className="display mt-6 text-5xl uppercase sm:text-6xl lg:text-8xl">One requirement.<br/><span className="text-metallic">Four clear moves.</span></h2><p className="mx-auto mt-7 max-w-2xl leading-8 text-muted">A specification-led workflow designed to reduce ambiguity between enquiry and dispatch.</p></div>
      <div className="mt-16 [perspective:1400px] lg:mt-24">
        <motion.div style={{rotateX,scale,y,transformOrigin:"center top"}} className="relative mx-auto aspect-[16/9] max-w-6xl overflow-hidden border border-white/15 bg-carbon shadow-[0_50px_140px_rgba(0,0,0,.6)]">
          <Image src="/images/product-range.jpg" alt="Sriyaan Metals industrial fastener range" fill sizes="(max-width:1200px) 100vw,1200px" className="object-cover"/>
          <div className="absolute inset-0 bg-gradient-to-t from-ink via-ink/15 to-transparent"/>
          <div className="absolute left-5 top-5 glass px-4 py-3 text-[.6rem] font-bold uppercase tracking-[.2em] text-teal sm:left-8 sm:top-8">Technical supply system</div>
          <div className="absolute bottom-5 left-5 right-5 grid grid-cols-2 gap-px bg-white/10 sm:bottom-8 sm:left-8 sm:right-8 lg:grid-cols-4">{STEPS.map(({icon:Icon,number,title,text})=><article key={number} className="bg-ink/88 p-4 backdrop-blur-md sm:p-5"><div className="flex items-center justify-between"><Icon className="text-teal" size={18}/><span className="text-[.6rem] text-muted">{number}</span></div><h3 className="mt-5 font-display text-base font-bold uppercase sm:text-lg">{title}</h3><p className="mt-2 hidden text-xs leading-5 text-muted sm:block">{text}</p></article>)}</div>
        </motion.div>
      </div>
      <div className="mt-14 flex justify-center"><Link href="/about" className="btn btn-secondary">How we work <ArrowUpRight size={16}/></Link></div>
    </div>
  </section>;
}
