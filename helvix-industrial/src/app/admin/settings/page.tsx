import { getSettings } from "@/lib/cms";
import { saveSettings } from "../actions";

const FIELDS = [
  ["companyName", "Company name"],
  ["legalName", "Legal name"],
  ["phone", "Phone"],
  ["email", "Email"],
  ["whatsapp", "WhatsApp"],
  ["officeAddress", "Office address"],
  ["factoryAddress", "Factory address"],
  ["hours", "Business hours"],
  ["mapsEmbed", "Google Maps embed URL"],
  ["linkedin", "LinkedIn"],
  ["instagram", "Instagram"],
  ["facebook", "Facebook"],
  ["youtube", "YouTube"],
  ["gaId", "Google Analytics ID"],
  ["gscVerification", "Search Console verification"],
];

export default async function AdminSettings() {
  const s = await getSettings();
  return (
    <div>
      <h1 className="display text-4xl">Settings</h1>
      <form action={saveSettings} className="mt-8 grid gap-4 max-w-2xl dark-form">
        {FIELDS.map(([key, label]) => (
          <label key={key} className="text-xs tracking-[0.16em] uppercase text-mist">
            {label}
            <input className="input mt-2" name={key} defaultValue={s[key] || ""} />
          </label>
        ))}
        <button className="btn btn-primary w-fit">Save settings</button>
      </form>
    </div>
  );
}
