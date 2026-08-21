import { NextResponse } from "next/server";
import { z } from "zod";

const schema = z.object({
  type: z.enum(["contact","quote","vendor"]),
  name: z.string().trim().min(2).max(120),
  email: z.string().email().max(180),
  phone: z.string().trim().min(7).max(30),
  company: z.string().max(180).optional().default(""),
  categories: z.string().max(400).optional().default(""),
  product: z.string().max(180).optional().default(""),
  requirement: z.string().max(300).optional().default(""),
  quantity: z.string().max(100).optional().default(""),
  message: z.string().trim().min(10).max(5000),
  website: z.string().max(0).optional().default(""),
});

const hits = new Map<string,{ count:number; start:number }>();
function limited(ip:string) { const now=Date.now(), item=hits.get(ip); if(!item||now-item.start>60_000){hits.set(ip,{count:1,start:now});return false;} item.count++; return item.count>6; }

export async function POST(request: Request) {
  const ip=(request.headers.get("x-forwarded-for")||"local").split(",")[0].trim();
  if(limited(ip)) return NextResponse.json({error:"Too many requests"},{status:429});
  const form=await request.formData();
  const parsed=schema.safeParse(Object.fromEntries(form.entries()));
  if(!parsed.success) return NextResponse.json({error:parsed.error.issues[0]?.message||"Invalid enquiry"},{status:400});
  // Production adapter: persist to PostgreSQL and send email after credentials are configured.
  console.info("Validated Sriyaan enquiry", { ...parsed.data, message: "[redacted from logs]", ip });
  return NextResponse.json({ok:true},{status:201});
}
