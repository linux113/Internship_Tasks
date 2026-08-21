import { NextRequest, NextResponse } from "next/server";
import { COOKIE, verifyAdmin } from "@/lib/auth";
export async function proxy(request:NextRequest){if(request.nextUrl.pathname==="/admin/login")return NextResponse.next();const token=request.cookies.get(COOKIE)?.value;if(!token||!await verifyAdmin(token)){const url=new URL("/admin/login",request.url);return NextResponse.redirect(url);}return NextResponse.next();}
export const config={matcher:["/admin/:path*"]};
