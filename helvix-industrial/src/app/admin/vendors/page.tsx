import { prisma } from "@/lib/prisma";
import { formatDate } from "@/lib/utils";
import { updateVendor } from "../actions";

export default async function AdminVendors() {
  const vendors = await prisma.vendor.findMany({ orderBy: { createdAt: "desc" } });
  return (
    <div>
      <h1 className="display text-4xl">Vendor applications</h1>
      <div className="mt-8 space-y-4">
        {vendors.map((v) => (
          <article key={v.id} className="border border-white/10 p-5">
            <p className="font-display uppercase tracking-wide text-lg">{v.companyName}</p>
            <p className="text-sm text-mist">
              {v.contactPerson} · {v.email} · {v.country} · {formatDate(v.createdAt)}
            </p>
            <p className="mt-3 text-haze">{v.message}</p>
            <p className="mt-2 text-sm text-mist">
              {v.categories} · {v.capacity} · {v.certifications}
            </p>
            <form action={updateVendor} className="mt-4 flex gap-3 dark-form">
              <input type="hidden" name="id" value={v.id} />
              <select name="status" defaultValue={v.status} className="input !w-auto">
                {["New", "Reviewing", "Approved", "Rejected"].map((s) => (
                  <option key={s}>{s}</option>
                ))}
              </select>
              <input name="notes" defaultValue={v.notes} className="input max-w-md" placeholder="Notes" />
              <button className="btn btn-ghost !min-h-10">Update</button>
            </form>
          </article>
        ))}
        {vendors.length === 0 && <p className="text-mist">No vendor applications yet.</p>}
      </div>
    </div>
  );
}
