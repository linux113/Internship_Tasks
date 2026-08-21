"use client";

import { useEffect, useRef, type ReactNode } from "react";
import gsap from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";

if (typeof window !== "undefined") gsap.registerPlugin(ScrollTrigger);

export function Reveal({ children, className = "", delay = 0 }: { children: ReactNode; className?: string; delay?: number }) {
  const ref = useRef<HTMLDivElement>(null);
  useEffect(() => {
    const el = ref.current;
    if (!el || matchMedia("(prefers-reduced-motion: reduce)").matches) return;
    const animation = gsap.to(el, { opacity: 1, y: 0, duration: .7, delay, ease: "power3.out", scrollTrigger: { trigger: el, start: "top 88%", once: true } });
    return () => { animation.scrollTrigger?.kill(); animation.kill(); };
  }, [delay]);
  return <div ref={ref} className={`reveal ${className}`}>{children}</div>;
}
