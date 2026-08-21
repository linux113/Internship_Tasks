"use client";

import { useState } from "react";
import { Send } from "lucide-react";

export function EnquiryForm({ type = "contact", product = "" }: { type?: "contact" | "quote" | "vendor"; product?: string }) {
  const [status, setStatus] = useState<"idle"|"loading"|"success"|"error">("idle");
  async function submit(formData: FormData) {
    setStatus("loading");
    const res = await fetch("/api/enquiries", { method: "POST", body: formData });
    setStatus(res.ok ? "success" : "error");
  }
  if (status === "success") return <div className="border border-teal/30 bg-teal/10 p-8 text-center"><p className="font-display text-2xl font-bold uppercase">Enquiry received</p><p className="mt-3 text-sm text-muted">Thank you. The Sriyaan Metals team will respond during business hours.</p></div>;
  return <form action={submit} className="grid gap-4" aria-label={`${type} form`}>
    <input type="hidden" name="type" value={type}/><input type="hidden" name="product" value={product}/><input className="hidden" name="website" tabIndex={-1} autoComplete="off" aria-hidden="true"/>
    {type === "vendor" && <label className="text-xs font-bold uppercase tracking-wider">Company name<input className="input mt-2" name="company" required minLength={2}/></label>}
    <div className="grid gap-4 sm:grid-cols-2"><label className="text-xs font-bold uppercase tracking-wider">Name<input className="input mt-2" name="name" required minLength={2}/></label><label className="text-xs font-bold uppercase tracking-wider">Phone<input className="input mt-2" name="phone" type="tel" required/></label></div>
    <div className="grid gap-4 sm:grid-cols-2"><label className="text-xs font-bold uppercase tracking-wider">Email<input className="input mt-2" name="email" type="email" required/></label><label className="text-xs font-bold uppercase tracking-wider">{type === "vendor" ? "Product categories" : "Company"}<input className="input mt-2" name={type === "vendor" ? "categories" : "company"}/></label></div>
    {type === "quote" && <div className="grid gap-4 sm:grid-cols-2"><label className="text-xs font-bold uppercase tracking-wider">Product / standard<input className="input mt-2" name="requirement" defaultValue={product}/></label><label className="text-xs font-bold uppercase tracking-wider">Quantity<input className="input mt-2" name="quantity"/></label></div>}
    <label className="text-xs font-bold uppercase tracking-wider">{type === "vendor" ? "Capability, capacity and certifications" : "Requirement details"}<textarea className="input mt-2 min-h-36 resize-y" name="message" required minLength={10}/></label>
    <button disabled={status === "loading"} className="btn btn-primary w-fit disabled:opacity-50">{status === "loading" ? "Sending…" : <>Send enquiry <Send size={15}/></>}</button>
    <p aria-live="polite" className="text-sm text-red-600">{status === "error" ? "We could not send this enquiry. Please call or WhatsApp us." : ""}</p>
  </form>;
}
