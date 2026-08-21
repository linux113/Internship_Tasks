import Link from "next/link";

export function MobileCta() {
  return (
    <div className="fixed inset-x-0 bottom-0 z-30 md:hidden border-t border-white/10 bg-ink/95 backdrop-blur">
      <div className="grid grid-cols-2">
        <Link href="/quote" className="py-3 text-center font-display tracking-[0.16em] uppercase text-xs bg-brass text-ink">
          Get a Quote
        </Link>
        <Link href="/contact" className="py-3 text-center font-display tracking-[0.16em] uppercase text-xs">
          Send Enquiry
        </Link>
      </div>
    </div>
  );
}
