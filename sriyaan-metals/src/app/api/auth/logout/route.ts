import { SESSION_COOKIE } from "@/lib/auth";
import { redirectPath } from "@/lib/request-url";

export async function POST() {
  const res = redirectPath("/admin/login");
  res.cookies.set(SESSION_COOKIE, "", { path: "/", maxAge: 0 });
  return res;
}
