"use client";

import { useState } from "react";

type Props = {
  productName?: string;
  productId?: string;
  type?: "product" | "general" | "quote" | "contact";
  dark?: boolean;
};

export function EnquiryForm({
  productName = "",
  productId = "",
  type = "general",
  dark = false,
}: Props) {
  const [status, setStatus] = useState<"idle" | "loading" | "ok" | "err">("idle");
  const [error, setError] = useState("");

  async function onSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();
    setStatus("loading");
    setError("");
    const form = e.currentTarget;
    const data = new FormData(form);
    try {
      const res = await fetch("/api/enquiries", { method: "POST", body: data });
      const json = await res.json();
      if (!res.ok) throw new Error(json.error || "Unable to send enquiry");
      setStatus("ok");
      form.reset();
    } catch (err) {
      setStatus("err");
      setError(err instanceof Error ? err.message : "Something went wrong");
    }
  }

  const field = dark ? "input" : "input";

  return (
    <form onSubmit={onSubmit} className={`grid gap-4 ${dark ? "dark-form" : ""}`}>
      <input type="hidden" name="type" value={type} />
      <input type="hidden" name="productId" value={productId} />
      <input type="text" name="website" className="hidden" tabIndex={-1} autoComplete="off" />
      <div className="grid sm:grid-cols-2 gap-4">
        <input className={field} name="name" placeholder="Name *" required />
        <input className={field} name="company" placeholder="Company" />
        <input className={field} name="email" type="email" placeholder="Email *" required />
        <input className={field} name="phone" placeholder="Phone" />
        <input className={field} name="country" placeholder="Country" />
        <input
          className={field}
          name="product"
          placeholder="Product"
          defaultValue={productName}
        />
        <input className={field} name="quantity" placeholder="Quantity" />
        <input className={field} name="spec" placeholder="Required specification" />
      </div>
      <textarea
        className={`${field} min-h-32`}
        name="message"
        placeholder="Message *"
        required
      />
      <label className="text-sm text-mist">
        Attach drawing or RFQ
        <input className="mt-2 block w-full text-sm" type="file" name="file" />
      </label>
      <button className="btn btn-primary w-fit" disabled={status === "loading"}>
        {status === "loading" ? "Sending…" : "Send Enquiry"}
      </button>
      {status === "ok" && (
        <p className="text-sm text-brass">
          Thank you. Our team will respond with a technical and commercial reply.
        </p>
      )}
      {status === "err" && <p className="text-sm text-copper">{error}</p>}
    </form>
  );
}
