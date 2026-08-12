"use client";

import { MessageCircle } from "lucide-react";
import { whatsappLink } from "@/lib/utils";

export function WhatsAppButton({
  number,
  message = "Hello Helvix, I would like to discuss a fastener requirement.",
}: {
  number: string;
  message?: string;
}) {
  return (
    <a
      href={whatsappLink(number, message)}
      target="_blank"
      rel="noopener noreferrer"
      className="fixed bottom-5 right-5 z-40 grid h-14 w-14 place-items-center bg-[#25D366] text-white shadow-lg hover:scale-105 transition-transform"
      aria-label="Chat on WhatsApp"
    >
      <MessageCircle />
    </a>
  );
}
