import Link from "next/link";

export default async function LoginPage({
  searchParams,
}: {
  searchParams: Promise<{ next?: string; error?: string }>;
}) {
  const { next = "/admin", error } = await searchParams;

  return (
    <div className="min-h-screen bg-ink grid place-items-center px-4">
      <form
        method="post"
        action="/api/auth/login"
        className="w-full max-w-md border border-white/10 p-10 dark-form"
      >
        <div className="flex items-center gap-3">
          <img src="/sriyaan-logo.jpeg" alt="" className="h-11 w-11 rounded-sm object-cover" />
          <p className="font-display tracking-[0.25em] text-xl">SRIYAAN METALS</p>
        </div>
        <h1 className="mt-7 display text-4xl">Admin access</h1>
        <input type="hidden" name="next" value={next.startsWith("/admin") ? next : "/admin"} />
        <div className="mt-8 space-y-4">
          <input className="input" name="email" type="email" placeholder="Email" autoComplete="username" required />
          <input className="input" name="password" type="password" placeholder="Password" autoComplete="current-password" required />
        </div>
        <button className="btn btn-primary mt-6 w-full" type="submit">Sign in</button>
        {error && <p className="mt-4 text-sm text-copper">Invalid email or password.</p>}
        <p className="mt-8 text-xs text-mist leading-relaxed">
          Access is restricted to authorized SRIYAAN METALS administrators.
        </p>
        <Link href="/" className="mt-6 inline-block text-xs tracking-[0.16em] uppercase text-brass">
          ← Back to website
        </Link>
      </form>
    </div>
  );
}
