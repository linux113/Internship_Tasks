import { prisma } from "@/lib/prisma";
import { requireSession } from "@/lib/auth";
import { saveUser } from "../actions";
import { redirect } from "next/navigation";

export default async function AdminUsers() {
  const session = await requireSession();
  if (!session) redirect("/admin/login");
  if (session.role !== "SUPER_ADMIN") {
    return <p>Only Super Admin can manage users.</p>;
  }
  const users = await prisma.user.findMany({ orderBy: { createdAt: "asc" } });
  return (
    <div>
      <h1 className="display text-4xl">Users & roles</h1>
      <table className="admin-table mt-8">
        <thead>
          <tr>
            <th>Name</th>
            <th>Email</th>
            <th>Role</th>
            <th>Active</th>
          </tr>
        </thead>
        <tbody>
          {users.map((u) => (
            <tr key={u.id}>
              <td>{u.name}</td>
              <td>{u.email}</td>
              <td>{u.role}</td>
              <td>{u.active ? "Yes" : "No"}</td>
            </tr>
          ))}
        </tbody>
      </table>
      <form action={saveUser} className="mt-10 grid md:grid-cols-2 gap-3 max-w-xl dark-form">
        <input className="input" name="name" placeholder="Name" required />
        <input className="input" name="email" type="email" placeholder="Email" required />
        <input className="input" name="password" type="password" placeholder="Password" />
        <select name="role" className="input">
          <option>CONTENT_MANAGER</option>
          <option>PRODUCT_MANAGER</option>
          <option>SALES</option>
          <option>SUPER_ADMIN</option>
        </select>
        <button className="btn btn-primary w-fit">Create user</button>
      </form>
    </div>
  );
}
