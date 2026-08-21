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
  company: "SRIYAAN METALS",
  legal: "SRIYAAN METALS",
  phone: "+91 96195 61657",
  email: "info@sriyaanmetals.co",
  whatsapp: "+91 96195 61657",
  address:
    "FLOOR-2, 204, PLOT NO.96/98, Platinum Arcade, JSS Road, Central Plaza Cinema, Charni Road, Opera House, Mumbai - 400004, Maharashtra, India",
};
