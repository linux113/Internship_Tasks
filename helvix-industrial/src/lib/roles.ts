export const ROLE_LABELS: Record<string, string> = {
  SUPER_ADMIN: "Super Admin",
  CONTENT_MANAGER: "Content Manager",
  PRODUCT_MANAGER: "Product Manager",
  SALES: "Sales / Admin",
};

export function canAccess(role: string, area: string) {
  if (role === "SUPER_ADMIN") return true;
  const map: Record<string, string[]> = {
    CONTENT_MANAGER: ["content", "blog", "media", "seo", "dashboard"],
    PRODUCT_MANAGER: ["products", "media", "dashboard"],
    SALES: ["enquiries", "vendors", "dashboard"],
  };
  return map[role]?.includes(area) ?? false;
}
