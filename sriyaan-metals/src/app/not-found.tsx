import Link from "next/link";

export default function NotFound() {
  return (
    <div className="min-h-screen bg-ink grid place-items-center px-6 text-center">
      <div>
        <p className="eyebrow justify-center">404</p>
        <h1 className="display text-6xl mt-4">Page not found</h1>
        <p className="mt-4 text-mist">The fastener you are looking for is not in this bin.</p>
        <Link href="/" className="btn btn-primary mt-8">
          Back to home
        </Link>
      </div>
    </div>
  );
}
