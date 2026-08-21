import Link from "next/link";
import { Reveal } from "@/components/site/Reveal";

function project(lat: number, lng: number) {
  const x = ((lng + 180) / 360) * 100;
  const y = ((90 - lat) / 180) * 100;
  return { x, y };
}

export function GlobalMap({
  countries,
}: {
  countries: { id: string; name: string; region: string; lat: number; lng: number }[];
}) {
  const regions = [...new Set(countries.map((c) => c.region))];

  return (
    <section className="relative bg-ink py-24 overflow-hidden">
      <div className="absolute inset-0 opacity-[0.14] pointer-events-none">
        <WorldSvg />
      </div>
      <div className="container-site relative">
        <Reveal>
          <p className="eyebrow">International enquiries</p>
          <h2 className="display text-5xl md:text-6xl mt-4 max-w-3xl">
            Discuss your destination with us.
          </h2>
          <p className="mt-6 max-w-2xl text-haze text-lg">
            Verified markets will appear on this map when configured by an administrator.
            Until then, contact our sales team with your destination and product requirement.
          </p>
        </Reveal>

        <div className="relative mt-14 aspect-[2/1] max-h-[520px] border border-white/8 bg-steel/40">
          <WorldSvg className="absolute inset-0 w-full h-full text-brass/40" />
          <svg className="absolute inset-0 w-full h-full" viewBox="0 0 100 50" preserveAspectRatio="none">
            {countries.map((c) => {
              const p = project(c.lat, c.lng);
              const origin = project(22, 78);
              return (
                <g key={c.id}>
                  <line
                    x1={origin.x}
                    y1={origin.y / 2}
                    x2={p.x}
                    y2={p.y / 2}
                    stroke="#c4a574"
                    strokeOpacity="0.28"
                    strokeWidth="0.12"
                  />
                </g>
              );
            })}
          </svg>
          {countries.map((c) => {
            const p = project(c.lat, c.lng);
            return (
              <span
                key={c.id}
                className="absolute h-2 w-2 rounded-full bg-brass map-dot"
                style={{ left: `${p.x}%`, top: `${p.y}%` }}
                title={c.name}
              />
            );
          })}
        </div>

        <div className="mt-10 grid sm:grid-cols-2 lg:grid-cols-5 gap-6">
          {regions.map((region) => (
            <div key={region}>
              <p className="font-display tracking-[0.2em] uppercase text-brass text-sm">{region}</p>
              <ul className="mt-2 text-sm text-mist space-y-1">
                {countries
                  .filter((c) => c.region === region)
                  .map((c) => (
                    <li key={c.id}>{c.name}</li>
                  ))}
              </ul>
            </div>
          ))}
        </div>
        <Link href="/global-reach" className="btn btn-ghost mt-12">
          View markets
        </Link>
      </div>
    </section>
  );
}

function WorldSvg({ className = "" }: { className?: string }) {
  return (
    <svg viewBox="0 0 1000 500" className={className} fill="none" aria-hidden>
      <path
        d="M150 90l40 10 30-20 50 8 20 30-10 40 40 10 10 30-30 20-60-10-40 20-30-30 10-50zM430 70l80 5 40 25-10 30 50 15 20 40-70 20-90-10-30-35 10-50zM720 110l60 10 40 35-20 40-70 10-40-25 10-40zM180 250l70 5 40 40-15 50-80 10-50-30 10-50zM480 260l90 10 30 40-40 50-100 5-20-40 20-45zM760 250l80 15 20 45-50 40-70-10-10-40zM820 360l50 10 20 30-80 20-20-25z"
        stroke="currentColor"
        strokeWidth="1.2"
        fill="currentColor"
        fillOpacity="0.05"
      />
      <path d="M40 250h920" stroke="currentColor" strokeOpacity="0.15" />
      <path d="M500 30v440" stroke="currentColor" strokeOpacity="0.08" />
    </svg>
  );
}
