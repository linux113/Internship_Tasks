"use client";

import Link from "next/link";
import { ParallaxLayer, ParallaxRoot } from "@/components/site/Parallax";

const TRUST = [
  "Quality Assured",
  "Global Supply",
  "Technical Expertise",
  "Reliable Delivery",
];

export function Hero({
  title,
  subtitle,
  bg,
  fg,
  ctaText,
  ctaUrl,
  secondaryText,
  secondaryUrl,
}: {
  title: string;
  subtitle: string;
  bg: string;
  fg: string;
  ctaText: string;
  ctaUrl: string;
  secondaryText: string;
  secondaryUrl: string;
}) {
  return (
    <ParallaxRoot className="relative min-h-[100svh] overflow-hidden bg-ink">
      <ParallaxLayer speed={0.15} className="absolute inset-[-18%] will-change-transform">
        <div
          className="absolute inset-0 bg-cover bg-center scale-110"
          style={{ backgroundImage: `url(${bg})` }}
        />
      </ParallaxLayer>

      <ParallaxLayer speed={0.22} className="absolute inset-0 will-change-transform">
        <div className="absolute inset-0 bg-gradient-to-b from-ink/55 via-ink/45 to-ink" />
        <div className="absolute inset-0 bg-gradient-to-r from-ink/70 via-transparent to-ink/40" />
      </ParallaxLayer>

      <ParallaxLayer
        speed={0.35}
        className="absolute right-[-8%] bottom-[-6%] w-[58%] max-w-3xl hidden md:block will-change-transform"
      >
        <div className="relative aspect-[4/3] overflow-hidden border border-white/10 shadow-[0_30px_80px_rgba(0,0,0,0.45)]">
          <div
            className="absolute inset-0 bg-cover bg-center"
            style={{ backgroundImage: `url(${fg})` }}
          />
          <div className="absolute inset-0 bg-gradient-to-tr from-ink/40 to-transparent" />
        </div>
      </ParallaxLayer>

      <div className="relative z-10 container-site min-h-[100svh] flex flex-col justify-end pb-24 pt-36">
        <ParallaxLayer speed={0.7} className="max-w-3xl will-change-transform">
          <p className="eyebrow">Helvix Industrial · Est. 1998</p>
          <h1 className="display text-[14vw] sm:text-7xl lg:text-[5.6rem] mt-6 whitespace-pre-line">
            {title}
          </h1>
          <p className="mt-7 max-w-xl text-lg text-haze leading-relaxed">{subtitle}</p>
        </ParallaxLayer>

        <ParallaxLayer speed={0.88} className="mt-10 will-change-transform">
          <div className="flex flex-wrap gap-3">
            <Link href={ctaUrl} className="btn btn-primary">
              {ctaText}
            </Link>
            <Link href={secondaryUrl} className="btn btn-ghost">
              {secondaryText}
            </Link>
          </div>
          <ul className="mt-12 flex flex-wrap gap-x-8 gap-y-3 text-[0.72rem] tracking-[0.22em] uppercase text-mist">
            {TRUST.map((item) => (
              <li key={item} className="flex items-center gap-2">
                <span className="h-px w-5 bg-brass" />
                {item}
              </li>
            ))}
          </ul>
        </ParallaxLayer>
      </div>
    </ParallaxRoot>
  );
}
