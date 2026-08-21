import { prisma } from "@/lib/prisma";
import { saveHomepage, saveCountry, saveWhy, saveIndustry, deleteIndustry, saveInfrastructure, deleteInfrastructure } from "../actions";

export default async function AdminContent() {
  const [home, countries, why, industries, infrastructure] = await Promise.all([
    prisma.homepage.findUnique({ where: { id: "homepage" } }),
    prisma.country.findMany({ orderBy: { sortOrder: "asc" } }),
    prisma.whyChoose.findMany({ orderBy: { sortOrder: "asc" } }),
    prisma.industry.findMany({ orderBy: { sortOrder: "asc" } }),
    prisma.infrastructureImage.findMany({ orderBy: { sortOrder: "asc" } }),
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
        <h2 className="display text-3xl">Industries</h2>
        <div className="mt-4 space-y-2">{industries.map((item) => <div key={item.id} className="flex justify-between border-b border-white/10 py-2"><span>{item.name}</span><form action={deleteIndustry}><input type="hidden" name="id" value={item.id}/><button className="text-copper">Delete</button></form></div>)}</div>
        <form action={saveIndustry} className="mt-5 grid md:grid-cols-2 gap-3 dark-form max-w-3xl">
          <input className="input" name="name" placeholder="Industry name" required />
          <input className="input" name="slug" placeholder="Slug (optional)" />
          <input className="input" name="image" placeholder="Image URL" />
          <input className="input" name="applications" placeholder="Applications" />
          <textarea className="input md:col-span-2" name="description" placeholder="Description" />
          <label className="text-sm"><input type="checkbox" name="published" /> Published</label>
          <button className="btn btn-ghost w-fit">Add industry</button>
        </form>
      </section>

      <section>
        <h2 className="display text-3xl">Infrastructure</h2>
        <div className="mt-4 space-y-2">{infrastructure.map((item) => <div key={item.id} className="flex justify-between border-b border-white/10 py-2"><span>{item.category} · {item.title}</span><form action={deleteInfrastructure}><input type="hidden" name="id" value={item.id}/><button className="text-copper">Delete</button></form></div>)}</div>
        <form action={saveInfrastructure} className="mt-5 grid md:grid-cols-2 gap-3 dark-form max-w-3xl">
          <input className="input" name="title" placeholder="Title" required />
          <select className="input" name="category"><option>Factory</option><option>Machinery</option><option>Warehouse</option><option>Packaging</option><option>Quality Inspection</option><option>Production</option></select>
          <input className="input" name="image" placeholder="Image URL" required />
          <input className="input" name="caption" placeholder="Description" />
          <label className="text-sm"><input type="checkbox" name="published" /> Published</label>
          <button className="btn btn-ghost w-fit">Add infrastructure</button>
        </form>
      </section>
      <section>
        <h2 className="display text-3xl">Export countries</h2>
        <p className="mt-2 text-mist text-sm">{countries.map((c) => c.name).join(" · ")}</p>
        <form action={saveCountry} className="mt-4 grid md:grid-cols-4 gap-3 dark-form max-w-3xl">
          <input className="input" name="name" placeholder="Country" />
          <input className="input" name="region" placeholder="Region" />
          <input className="input" name="flag" placeholder="Flag image URL" />
          <input className="input" name="description" placeholder="Export information" />
          <input className="input" name="lat" placeholder="Lat" />
          <input className="input" name="lng" placeholder="Lng" />
          <button className="btn btn-ghost w-fit">Add country</button>
        </form>
      </section>
    </div>
  );
}
