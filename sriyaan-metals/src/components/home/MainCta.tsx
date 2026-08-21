import Link from "next/link";
import { ParallaxLayer, ParallaxRoot } from "@/components/site/Parallax";

export function MainCta({
  title,
  body,
  button,
  url,
  image,
}: {
  title: string;
  body: string;
  button: string;
  url: string;
  image: string;
}) {
  return (
    <ParallaxRoot className="relative min-h-[70vh] overflow-hidden">
      <ParallaxLayer speed={0.2} className="absolute inset-[-16%]">
        <div
          className="absolute inset-0 bg-cover bg-center"
          style={{ backgroundImage: `url(${image})` }}
        />
      </ParallaxLayer>
      <div className="absolute inset-0 bg-ink/75" />
      <div className="relative z-10 container-site py-28">
        <p className="eyebrow">Next step</p>
        <h2 className="display text-5xl md:text-7xl mt-4 whitespace-pre-line max-w-4xl">
          {title}
        </h2>
        <p className="mt-6 max-w-xl text-lg text-haze">{body}</p>
        <div className="mt-10 flex flex-wrap gap-3">
          <Link href={url} className="btn btn-primary">
            {button}
          </Link>
          <Link href="/contact" className="btn btn-ghost">
            Send Enquiry
          </Link>
        </div>
      </div>
    </ParallaxRoot>
  );
}
