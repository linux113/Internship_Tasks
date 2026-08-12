import { prisma } from "@/lib/prisma";
import { saveHomepage, saveCountry, saveWhy } from "../actions";

export default async function AdminContent() {
  const [home, countries, why] = await Promise.all([
    prisma.homepage.findUnique({ where: { id: "homepage" } }),
    prisma.country.findMany({ orderBy: { sortOrder: "asc" } }),
    prisma.whyChoose.findMany({ orderBy: { sortOrder: "asc" } }),
  ]);
  return (
    <div className="space-y-16">
      <section>
        <h1 className="display text-4xl">Homepage CMS</h1>
        <form action={saveHomepage} className="mt-8 grid gap-3 max-w-3xl dark-form">
          <textarea className="input min-h-24" name="heroTitle" defaultValue={home?.heroTitle} />
          <textarea className="input min-h-24" name="heroSubtitle" defaultValue={home?.heroSubtitle} />
          <input className="input" name="heroBg" defaultValue={home?.heroBg} placeholder="Hero background" />
          <input className="input" name="heroFg" defaultValue={home?.heroFg} placeholder="Hero foreground" />
          <div className="grid md:grid-cols-2 gap-3">
            <input className="input" name="heroCtaText" defaultValue={home?.heroCtaText} />
            <input className="input" name="heroCtaUrl" defaultValue={home?.heroCtaUrl} />
            <input className="input" name="heroSecondaryText" defaultValue={home?.heroSecondaryText} />
            <input className="input" name="heroSecondaryUrl" defaultValue={home?.heroSecondaryUrl} />
          </div>
          <input className="input" name="aboutTitle" defaultValue={home?.aboutTitle} />
          <textarea className="input min-h-32" name="aboutBody" defaultValue={home?.aboutBody} />
          <input className="input" name="aboutImage" defaultValue={home?.aboutImage} />
          <input className="input" name="ctaTitle" defaultValue={home?.ctaTitle} />
          <textarea className="input" name="ctaBody" defaultValue={home?.ctaBody} />
          <textarea className="input" name="importBody" defaultValue={home?.importBody} />
          <textarea className="input" name="exportBody" defaultValue={home?.exportBody} />
          <button className="btn btn-primary w-fit">Save homepage</button>
        </form>
      </section>

      <section>
        <h2 className="display text-3xl">Why Choose Us</h2>
        <ul className="mt-4 text-sm text-haze space-y-1">
          {why.map((w) => (
            <li key={w.id}>
              {w.title} — {w.description}
            </li>
          ))}
        </ul>
        <form action={saveWhy} className="mt-4 grid md:grid-cols-3 gap-3 dark-form max-w-3xl">
          <input className="input" name="title" placeholder="Title" />
          <input className="input" name="description" placeholder="Description" />
          <input className="input" name="icon" placeholder="icon (shield/clock/scale/grid/globe/tool)" />
          <button className="btn btn-ghost w-fit">Add item</button>
        </form>
      </section>

      <section>
        <h2 className="display text-3xl">Export countries</h2>
        <p className="mt-2 text-mist text-sm">{countries.map((c) => c.name).join(" · ")}</p>
        <form action={saveCountry} className="mt-4 grid md:grid-cols-4 gap-3 dark-form max-w-3xl">
          <input className="input" name="name" placeholder="Country" />
          <input className="input" name="region" placeholder="Region" />
          <input className="input" name="lat" placeholder="Lat" />
          <input className="input" name="lng" placeholder="Lng" />
          <button className="btn btn-ghost w-fit">Add country</button>
        </form>
      </section>
    </div>
  );
}
