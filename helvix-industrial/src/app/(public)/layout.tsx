import { Header } from "@/components/site/Header";
import { Footer } from "@/components/site/Footer";
import { WhatsAppButton } from "@/components/site/WhatsAppButton";
import { MobileCta } from "@/components/site/MobileCta";
import { Analytics } from "@/components/site/Analytics";
import { getSettings } from "@/lib/cms";

export default async function PublicLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const s = await getSettings();
  return (
    <>
      <Analytics gaId={s.gaId} />
      <Header whatsapp={s.whatsapp} />
      <main className="flex-1 pb-14 md:pb-0">{children}</main>
      <Footer />
      <WhatsAppButton number={s.whatsapp || "+919876543210"} />
      <MobileCta />
    </>
  );
}
