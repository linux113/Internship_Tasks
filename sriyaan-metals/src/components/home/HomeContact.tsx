import { EnquiryForm } from "@/components/site/EnquiryForm";
import { Reveal } from "@/components/site/Reveal";

export function HomeContact({
  phone,
  email,
  address,
}: {
  phone: string;
  email: string;
  address: string;
}) {
  return (
    <section className="bg-paper text-ink py-24" id="enquiry">
      <div className="container-site grid lg:grid-cols-2 gap-16">
        <Reveal>
          <p className="eyebrow">Contact</p>
          <h2 className="display text-5xl mt-4">Send an enquiry</h2>
          <p className="mt-5 text-[#5a616c] max-w-md">
            Share the standard, grade, quantity and destination. We reply with
            availability, documentation and a commercial offer.
          </p>
          <dl className="mt-10 space-y-4 text-sm">
            <div>
              <dt className="uppercase tracking-[0.18em] text-xs text-brass-deep">Phone</dt>
              <dd className="mt-1">{phone}</dd>
            </div>
            <div>
              <dt className="uppercase tracking-[0.18em] text-xs text-brass-deep">Email</dt>
              <dd className="mt-1">{email}</dd>
            </div>
            <div>
              <dt className="uppercase tracking-[0.18em] text-xs text-brass-deep">Works</dt>
              <dd className="mt-1 max-w-sm">{address}</dd>
            </div>
          </dl>
        </Reveal>
        <Reveal delay={0.08}>
          <EnquiryForm type="general" />
        </Reveal>
      </div>
    </section>
  );
}
