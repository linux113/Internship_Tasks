"use client";
import { usePathname } from "next/navigation";
import { Header } from "./Header";
import { Footer } from "./Footer";
import { company } from "@/lib/site-data";
export function SiteChrome({children}:{children:React.ReactNode}){const path=usePathname();if(path.startsWith("/admin"))return <>{children}</>;return <><Header/><main>{children}</main><Footer/><a href={`https://wa.me/${company.whatsapp}?text=${encodeURIComponent("Hello Sriyaan Metals, I would like to discuss a fastener requirement.")}`} target="_blank" rel="noreferrer" className="fixed bottom-5 right-5 z-40 grid h-14 w-14 place-items-center rounded-full bg-[#25D366] text-xs font-black text-ink shadow-2xl" aria-label="Chat with Sriyaan Metals on WhatsApp">WA</a></>}
