"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import type { SessionUser } from "@/lib/types";
import { canAccess } from "@/lib/roles";

const LINKS = [
  { href: "/admin", label: "Dashboard", area: "dashboard" },
  { href: "/admin/products", label: "Products", area: "products" },
  { href: "/admin/categories", label: "Categories", area: "products" },
  { href: "/admin/enquiries", label: "Enquiries", area: "enquiries" },
  { href: "/admin/vendors", label: "Vendors", area: "vendors" },
  { href: "/admin/blog", label: "Blog", area: "blog" },
  { href: "/admin/content", label: "Content", area: "content" },
  { href: "/admin/customers", label: "Customers", area: "content" },
  { href: "/admin/certifications", label: "Certifications", area: "content" },
  { href: "/admin/media", label: "Media", area: "media" },
  { href: "/admin/seo", label: "SEO", area: "seo" },
  { href: "/admin/settings", label: "Settings", area: "dashboard" },
  { href: "/admin/users", label: "Users", area: "users" },
];

export function AdminShell({
  user,
  children,
}: {
  user: SessionUser;
  children: React.ReactNode;
}) {
  const path = usePathname();

  return (
    <div className="min-h-screen bg-[#0c0e12] text-paper flex">
      <aside className="w-64 shrink-0 border-r border-white/8 p-6 hidden md:block">
        <Link href="/admin" className="font-display tracking-[0.28em] text-xl">
          HELVIX
        </Link>
        <p className="text-[0.62rem] tracking-[0.22em] uppercase text-mist mt-1">Admin</p>
        <nav className="mt-8 flex flex-col gap-1 text-sm">
          {LINKS.filter((l) => user.role === "SUPER_ADMIN" || canAccess(user.role, l.area)).map(
            (l) => (
              <Link
                key={l.href}
                href={l.href}
                className={`px-3 py-2 ${
                  path === l.href || (l.href !== "/admin" && path.startsWith(l.href))
                    ? "bg-white/8 text-brass"
                    : "text-haze hover:text-paper"
                }`}
              >
                {l.label}
              </Link>
            ),
          )}
        </nav>
      </aside>
      <div className="flex-1 min-w-0">
        <header className="h-16 border-b border-white/8 flex items-center justify-between px-6">
          <p className="text-sm text-mist">
            {user.name} · {user.role.replace("_", " ")}
          </p>
          <div className="flex gap-4 text-sm">
            <Link href="/" className="text-brass">
              View site
            </Link>
            <form action="/api/auth/logout" method="post">
              <button type="submit" className="text-haze hover:text-paper">
                Sign out
              </button>
            </form>
          </div>
        </header>
        <div className="p-6 md:p-10">{children}</div>
      </div>
    </div>
  );
}
