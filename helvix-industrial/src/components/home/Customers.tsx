export function Customers({
  customers,
}: {
  customers: { id: string; name: string; logo: string }[];
}) {
  const loop = [...customers, ...customers];
  return (
    <section className="bg-ink py-20 overflow-hidden">
      <div className="container-site">
        <p className="eyebrow">Relationships</p>
        <h2 className="display text-4xl md:text-5xl mt-4">Trusted By Industry Leaders</h2>
      </div>
      <div className="mt-12 relative">
        <div className="flex w-max marquee-track gap-6 px-6">
          {loop.map((c, i) => (
            <div
              key={`${c.id}-${i}`}
              className="w-56 h-24 border border-white/10 grid place-items-center shrink-0"
            >
              <img src={c.logo} alt={c.name} className="max-h-12 opacity-80" />
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
