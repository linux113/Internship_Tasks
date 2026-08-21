import { prisma } from "@/lib/prisma";
import { requireSession } from "@/lib/auth";
import { redirect } from "next/navigation";
import Link from "next/link";
import { formatDate } from "@/lib/utils";

export default async function AdminHome() {
  const session = await requireSession();
  if (!session) redirect("/admin/login");

  const [products, categories, enquiries, vendors, posts, customers, testimonials] =
    await Promise.all([
      prisma.product.count(),
      prisma.category.count(),
      prisma.enquiry.count(),
      prisma.vendor.count(),
      prisma.blog.count(),
      prisma.customer.count(),
      prisma.testimonial.count(),
    ]);

  const recent = await prisma.enquiry.findMany({
    orderBy: { createdAt: "desc" },
    take: 6,
  });

  const stats = [
    ["Products", products, "/admin/products"],
    ["Categories", categories, "/admin/categories"],
    ["Enquiries", enquiries, "/admin/enquiries"],
    ["Vendors", vendors, "/admin/vendors"],
    ["Blog posts", posts, "/admin/blog"],
    ["Customers", customers, "/admin/customers"],
    ["Testimonials", testimonials, "/admin/customers"],
  ] as const;

  return (
    <div>
      <h1 className="display text-4xl">Dashboard</h1>
      <p className="text-mist mt-2">Operations snapshot for SRIYAAN METALS.</p>
      <div className="mt-10 grid sm:grid-cols-2 lg:grid-cols-4 gap-4">
        {stats.map(([label, n, href]) => (
          <Link key={label} href={href} className="border border-white/10 p-6 hover:border-brass/50">
            <p className="text-xs tracking-[0.2em] uppercase text-mist">{label}</p>
            <p className="display text-5xl mt-3">{n}</p>
          </Link>
        ))}
      </div>
      <h2 className="mt-14 font-display uppercase tracking-wide text-xl">Recent enquiries</h2>
      <table className="admin-table mt-4">
        <thead>
          <tr>
            <th>Date</th>
            <th>Customer</th>
            <th>Company</th>
            <th>Product</th>
            <th>Status</th>
          </tr>
        </thead>
        <tbody>
          {recent.map((e) => (
            <tr key={e.id}>
              <td>{formatDate(e.createdAt)}</td>
              <td>{e.name}</td>
              <td>{e.company}</td>
              <td>{e.productName}</td>
              <td>{e.status}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
