import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import { SESSION_COOKIE, signSession, verifyPassword } from "@/lib/auth";
import { loginSchema } from "@/lib/validations";
import { cookieOptions, publicOrigin, redirectPath } from "@/lib/request-url";

const attempts = new Map<string, { count: number; resetAt: number }>();
function isRateLimited(key: string) {
  const now = Date.now();
  const record = attempts.get(key);
  if (!record || now > record.resetAt) {
    attempts.set(key, { count: 1, resetAt: now + 10 * 60_000 });
    return false;
  }
  record.count += 1;
  return record.count > 5;
}

async function authenticate(email: string, password: string) {
  const parsed = loginSchema.safeParse({ email, password });
  if (!parsed.success) return null;
  const user = await prisma.user.findUnique({
    where: { email: parsed.data.email },
  });
  if (!user || user.active === false) return null;
  const ok = await verifyPassword(parsed.data.password, String(user.passwordHash));
  if (!ok) return null;
  return {
    id: String(user.id),
    name: String(user.name),
    email: String(user.email),
    role: String(user.role),
  };
}

export async function POST(request: Request) {
  const clientKey = (request.headers.get("x-forwarded-for") || "local").split(",")[0].trim();
  if (isRateLimited(clientKey)) {
    return NextResponse.json({ error: "Too many login attempts" }, { status: 429 });
  }

  const contentType = request.headers.get("content-type") || "";
  let email = "";
  let password = "";
  let next = "/admin";

  if (contentType.includes("application/json")) {
    const body = await request.json().catch(() => null);
    email = body?.email || "";
    password = body?.password || "";
    next = body?.next || "/admin";
  } else {
    const form = await request.formData();
    email = String(form.get("email") || "");
    password = String(form.get("password") || "");
    next = String(form.get("next") || "/admin");
  }

  if (!next.startsWith("/admin")) next = "/admin";

  const user = await authenticate(email, password);
  const { isHttps } = publicOrigin(request);
  const options = cookieOptions(isHttps);

  if (!user) {
    if (contentType.includes("application/json")) {
      return NextResponse.json({ error: "Invalid credentials" }, { status: 401 });
    }
    return redirectPath("/admin/login?error=1");
  }

  const token = await signSession(user);

  if (contentType.includes("application/json")) {
    const res = NextResponse.json({ ok: true, role: user.role, redirect: next });
    res.cookies.set(SESSION_COOKIE, token, options);
    return res;
  }

  const res = redirectPath(next);
  res.cookies.set(SESSION_COOKIE, token, options);
  return res;
}
