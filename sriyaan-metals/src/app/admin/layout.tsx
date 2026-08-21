import { requireSession } from "@/lib/auth";
import { AdminShell } from "@/components/admin/AdminShell";

export default async function AdminLayout({ children }: { children: React.ReactNode }) {
  const session = await requireSession();
  if (!session) return <>{children}</>;
  return <AdminShell user={session}>{children}</AdminShell>;
}
