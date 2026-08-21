import { prisma } from "@/lib/prisma";
import { deleteCertification, saveCertification } from "../actions";

export default async function AdminCerts() {
  const certs = await prisma.certification.findMany({ orderBy: { sortOrder: "asc" } });
  return (
    <div>
      <h1 className="display text-4xl">Certifications</h1>
      <form action={saveCertification} className="mt-8 grid gap-3 max-w-2xl dark-form">
        <input className="input" name="name" placeholder="Name" required />
        <input className="input" name="issuer" placeholder="Issuing authority" />
        <input className="input" name="certificateNumber" placeholder="Certificate number" />
        <div className="grid sm:grid-cols-2 gap-3">
          <label className="text-xs text-mist">Issue date<input className="input mt-1" name="issueDate" type="date" /></label>
          <label className="text-xs text-mist">Expiry date<input className="input mt-1" name="expiryDate" type="date" /></label>
        </div>
        <textarea className="input" name="description" placeholder="Description" />
        <input className="input" name="image" placeholder="Image path" />
        <input className="input" name="fileUrl" placeholder="Document URL" />
        <button className="btn btn-primary w-fit">Add certificate</button>
      </form>
      <table className="admin-table mt-10">
        <thead>
          <tr>
            <th>Name</th>
            <th>Issuer</th>
            <th></th>
          </tr>
        </thead>
        <tbody>
          {certs.map((c) => (
            <tr key={c.id}>
              <td>{c.name}</td>
              <td>{c.issuer}</td>
              <td>
                <form action={deleteCertification}>
                  <input type="hidden" name="id" value={c.id} />
                  <button className="text-copper">Delete</button>
                </form>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
