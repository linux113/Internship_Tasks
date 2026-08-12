"use client";

import { useEffect, useRef, type ReactNode } from "react";
import gsap from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";

if (typeof window !== "undefined") {
  gsap.registerPlugin(ScrollTrigger);
}

export function ParallaxRoot({
  children,
  className = "",
  id,
}: {
  children: ReactNode;
  className?: string;
  id?: string;
}) {
  const ref = useRef<HTMLElement>(null);

  useEffect(() => {
    const root = ref.current;
    if (!root) return;
    const reduce = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
    if (reduce) return;
    const mobile = window.matchMedia("(max-width: 768px)").matches;
    const intensity = mobile ? 0.32 : 1;

    const ctx = gsap.context(() => {
      root.querySelectorAll<HTMLElement>("[data-speed]").forEach((layer) => {
        const speed = Number(layer.dataset.speed || "1");
        const travel = (1 - speed) * 220 * intensity;
        gsap.fromTo(
          layer,
          { y: -travel * 0.15 },
          {
            y: travel,
            ease: "none",
            scrollTrigger: {
              trigger: root,
              start: "top bottom",
              end: "bottom top",
              scrub: 0.65,
            },
          },
        );
      });
    }, root);

    return () => ctx.revert();
  }, []);

  return (
    <section ref={ref} id={id} className={className}>
      {children}
    </section>
  );
}

export function ParallaxLayer({
  speed,
  className = "",
  children,
}: {
  speed: number;
  className?: string;
  children?: ReactNode;
}) {
  return (
    <div data-speed={speed} className={className}>
      {children}
    </div>
  );
}
