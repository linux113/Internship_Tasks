import { prisma } from "./prisma";
import { cache } from "react";

export const getSettings = cache(async () => {
  const rows = await prisma.setting.findMany();
  return Object.fromEntries(rows.map((row) => [row.key, row.value])) as Record<
    string,
    string
  >;
});

export const getHomepage = cache(async () => {
  return prisma.homepage.findUnique({ where: { id: "homepage" } });
});

export async function getSetting(key: string, fallback = "") {
  const settings = await getSettings();
  return settings[key] ?? fallback;
}

export const defaults = {
  company: "Helvix Industrial",
  legal: "Helvix Industrial Fasteners Pvt. Ltd.",
  phone: "+91 79 4000 2800",
  email: "ivan.p@example.net",
  whatsapp: "+91 98765 43210",
  address:
    "Plot 42, GIDC Industrial Estate, Sanand, Ahmedabad, Gujarat 382170, India",
};
