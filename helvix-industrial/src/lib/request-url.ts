import { NextResponse } from "next/server";

export function publicOrigin(request: Request) {
  const forwardedHost = request.headers.get("x-forwarded-host");
  const hostHeader = request.headers.get("host") || "localhost:3000";
  let host = (forwardedHost || hostHeader).split(",")[0].trim();
  if (host.startsWith("0.0.0.0")) host = host.replace("0.0.0.0", "localhost");

  const forwardedProto = request.headers.get("x-forwarded-proto");
  const proto =
    forwardedProto?.split(",")[0].trim() ||
    (host.includes("localhost") || host.startsWith("127.") ? "http" : "https");

  return {
    origin: `${proto}://${host}`,
    host,
    proto,
    isHttps: proto === "https",
  };
}

export function absolutePath(path: string) {
  return path.startsWith("/") ? path : `/${path}`;
}

export function redirectPath(path: string, status = 303) {
  return new NextResponse(null, {
    status,
    headers: { Location: absolutePath(path) },
  });
}

export function cookieOptions(isHttps: boolean) {
  return {
    httpOnly: true,
    sameSite: "lax" as const,
    secure: isHttps,
    path: "/",
    maxAge: 60 * 60 * 24 * 7,
  };
}
