import { NextResponse } from "next/server";
import { compare } from "bcryptjs";
import { COOKIE, signAdmin } from "@/lib/auth";

export async function POST(request:Request){
  if(process.env.NODE_ENV==="production"&&!process.env.AUTH_SECRET) return NextResponse.json({error:"Admin authentication is not configured"},{status:503});
  const form=await request.formData(); const email=String(form.get("email")||"").toLowerCase(); const password=String(form.get("password")||"");
  const expectedEmail=(process.env.ADMIN_EMAIL||"admin@sriyaan.local").toLowerCase();
  const ok=process.env.ADMIN_PASSWORD_HASH?await compare(password,process.env.ADMIN_PASSWORD_HASH):process.env.NODE_ENV!=="production"&&password==="SriyaanAdmin2026!";
  if(email!==expectedEmail||!ok) return NextResponse.redirect(new URL("/admin/login?error=1",request.url),303);
  const response=NextResponse.redirect(new URL("/admin",request.url),303); response.cookies.set(COOKIE,await signAdmin(email),{httpOnly:true,secure:process.env.NODE_ENV==="production",sameSite:"lax",path:"/",maxAge:60*60*8}); return response;
}
