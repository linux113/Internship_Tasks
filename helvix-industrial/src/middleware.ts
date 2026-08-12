import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";

export function middleware(request: NextRequest) {
  try {
    const { pathname } = request.nextUrl;
    if (pathname.startsWith("/admin") && pathname !== "/admin/login") {
      const token = request.cookies.get("helvix_session")?.value;
      if (!token) {
        const url = request.nextUrl.clone();
        url.pathname = "/admin/login";
        url.search = "?next=" + encodeURIComponent(pathname);
        return NextResponse.redirect(url);
      }
    }
    return NextResponse.next();
  } catch {
    return NextResponse.next();
  }
}

export const config = {
  matcher: ["/admin/:path*"],
};
