"use client";

import { useState } from "react";

export function VendorForm() {
  const [status, setStatus] = useState<"idle" | "loading" | "ok" | "err">("idle");
  const [error, setError] = useState("");

  async function onSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();
    setStatus("loading");
    const form = e.currentTarget;
    try {
      const res = await fetch("/api/vendors", { method: "POST", body: new FormData(form) });
      const json = await res.json();
      if (!res.ok) throw new Error(json.error || "Unable to submit");
      setStatus("ok");
      form.reset();
    } catch (err) {
      setStatus("err");
      setError(err instanceof Error ? err.message : "Error");
    }
  }

  return (
    <form onSubmit={onSubmit} className="grid gap-4">
      <input type="text" name="honeypot" className="hidden" tabIndex={-1} autoComplete="off" />
      <div className="grid sm:grid-cols-2 gap-4">
        <input className="input" name="companyName" placeholder="Company Name *" required />
        <input className="input" name="contactPerson" placeholder="Contact Person *" required />
        <input className="input" name="email" type="email" placeholder="Email *" required />
        <input className="input" name="phone" placeholder="Phone" />
        <input className="input" name="country" placeholder="Country" />
        <input className="input" name="website" placeholder="Website" />
        <input className="input sm:col-span-2" name="categories" placeholder="Product Categories" />
        <input className="input" name="capacity" placeholder="Production Capacity" />
        <input className="input" name="certifications" placeholder="Certifications" />
      </div>
      <textarea className="input min-h-24" name="capability" placeholder="Manufacturing Capability" />
      <textarea className="input min-h-28" name="message" placeholder="Message *" required />
      <label className="text-sm text-[#5a616c]">
        Company profile
        <input type="file" name="file" className="mt-2 block" />
      </label>
      <button className="btn btn-primary w-fit" disabled={status === "loading"}>
        {status === "loading" ? "Submitting…" : "Submit application"}
      </button>
      {status === "ok" && (
        <p className="text-sm text-brass-deep">Received. Our sourcing team will review your profile.</p>
      )}
      {status === "err" && <p className="text-sm text-copper">{error}</p>}
    </form>
  );
}
