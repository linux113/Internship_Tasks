import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";
import { jwtVerify } from "jose";

const SECRET = new TextEncoder().encode(
  process.env.AUTH_SECRET || "helvix-dev-secret-change-me",
);

function relativeRedirect(path: string) {
  return new NextResponse(null, {
    status: 303,
    headers: { Location: path },
  });
}

export async function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl;

  if (pathname.startsWith("/admin") && pathname !== "/admin/login") {
    const token = request.cookies.get("helvix_session")?.value;
    if (!token) {
      const next = encodeURIComponent(pathname);
      return relativeRedirect(`/admin/login?next=${next}`);
    }
    try {
      await jwtVerify(token, SECRET);
    } catch {
      return relativeRedirect("/admin/login");
    }
  }

  if (pathname === "/admin/login") {
    const token = request.cookies.get("helvix_session")?.value;
    if (token) {
      try {
        await jwtVerify(token, SECRET);
        return relativeRedirect("/admin");
      } catch {
        /* stay on login */
      }
    }
  }

  return NextResponse.next();
}

export const config = {
  matcher: ["/admin/:path*"],
};
