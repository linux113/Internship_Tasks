import { prisma } from "@/lib/prisma";
import { deleteCustomer, saveCustomer, saveTestimonial } from "../actions";

export default async function AdminCustomers() {
  const [customers, testimonials] = await Promise.all([
    prisma.customer.findMany({ orderBy: { sortOrder: "asc" } }),
    prisma.testimonial.findMany({ orderBy: { sortOrder: "asc" } }),
  ]);
  return (
    <div className="space-y-14">
      <section>
        <h1 className="display text-4xl">Customers</h1>
        <form action={saveCustomer} className="mt-6 grid md:grid-cols-3 gap-3 dark-form max-w-3xl">
          <input className="input" name="name" placeholder="Name" required />
          <input className="input" name="logo" placeholder="Logo path" />
          <input className="input" name="website" placeholder="Website" />
          <button className="btn btn-primary w-fit">Add customer</button>
        </form>
        <table className="admin-table mt-6">
          <thead>
            <tr>
              <th>Name</th>
              <th>Logo</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            {customers.map((c) => (
              <tr key={c.id}>
                <td>{c.name}</td>
                <td>{c.logo}</td>
                <td>
                  <form action={deleteCustomer}>
                    <input type="hidden" name="id" value={c.id} />
                    <button className="text-copper">Delete</button>
                  </form>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </section>
      <section>
        <h2 className="display text-3xl">Testimonials</h2>
        <form action={saveTestimonial} className="mt-6 grid gap-3 dark-form max-w-3xl">
          <textarea className="input min-h-24" name="quote" placeholder="Quote" required />
          <div className="grid md:grid-cols-3 gap-3">
            <input className="input" name="name" placeholder="Name" />
            <input className="input" name="company" placeholder="Company" />
            <input className="input" name="designation" placeholder="Designation" />
          </div>
          <button className="btn btn-primary w-fit">Add testimonial</button>
        </form>
        <ul className="mt-6 space-y-3 text-haze">
          {testimonials.map((t) => (
            <li key={t.id}>
              “{t.quote}” — {t.name}, {t.company}
            </li>
          ))}
        </ul>
      </section>
    </div>
  );
}
