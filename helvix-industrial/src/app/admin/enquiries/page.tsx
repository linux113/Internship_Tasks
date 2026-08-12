import { prisma } from "@/lib/prisma";
import { formatDate } from "@/lib/utils";
import { updateEnquiry } from "../actions";

const STATUSES = ["New", "Contacted", "Quoted", "Follow-up", "Won", "Lost"];

export default async function AdminEnquiries() {
  const enquiries = await prisma.enquiry.findMany({ orderBy: { createdAt: "desc" } });
  return (
    <div>
      <h1 className="display text-4xl">Enquiries</h1>
      <div className="mt-8 space-y-4">
        {enquiries.map((e) => (
          <article key={e.id} className="border border-white/10 p-5">
            <div className="flex flex-wrap justify-between gap-3">
              <div>
                <p className="font-display uppercase tracking-wide text-lg">{e.name}</p>
                <p className="text-sm text-mist">
                  {e.company} · {e.country} · {e.email} · {e.phone}
                </p>
              </div>
              <p className="text-sm text-brass">{e.type} · {formatDate(e.createdAt)}</p>
            </div>
            <p className="mt-3 text-sm">
              <strong>{e.productName}</strong> {e.quantity && `· ${e.quantity}`}
            </p>
            <p className="mt-2 text-haze">{e.message}</p>
            {e.spec && <p className="mt-1 text-sm text-mist">Spec: {e.spec}</p>}
            <form action={updateEnquiry} className="mt-4 flex flex-wrap gap-3 items-center dark-form">
              <input type="hidden" name="id" value={e.id} />
              <select name="status" defaultValue={e.status} className="input !w-auto">
                {STATUSES.map((s) => (
                  <option key={s}>{s}</option>
                ))}
              </select>
              <input name="notes" defaultValue={e.notes} placeholder="Internal notes" className="input max-w-md" />
              <button className="btn btn-ghost !min-h-10">Update</button>
            </form>
          </article>
        ))}
      </div>
    </div>
  );
}
