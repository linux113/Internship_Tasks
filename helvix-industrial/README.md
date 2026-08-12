# Helvix Industrial

Premium B2B website and CMS for an international industrial fastener manufacturer and exporter.

**Precision Fasteners. Reliable Supply. Global Reach.**

## Stack

- Next.js 16 (App Router) + TypeScript + Tailwind CSS 4
- GSAP ScrollTrigger layered parallax
- File-based CMS store (`data/db.json`) with a Prisma-shaped API
- `prisma/schema.prisma` is the production PostgreSQL model
- Zod validation, jose sessions, bcrypt passwords
- Server-rendered SEO, sitemap, robots, JSON-LD

## Quick start

```bash
cd helvix-industrial
npm install
npx tsx prisma/seed.ts
npm run dev
```

Open [http://localhost:3000](http://localhost:3000)

### Admin

- URL: `/admin`
- Email: `nina.v@example.com`
- Password: `HelvixAdmin2026!`

Roles: Super Admin, Content Manager, Product Manager, Sales.

## What is included

### Public site

Home (16 cinematic sections), product catalogue with filters, product detail + WhatsApp prefill, about, quality, manufacturing, industries, global reach, import/export, customers, vendor registration, blog, contact, quote, search, privacy, terms.

### Admin CMS

Dashboard, products, categories, enquiries (status + notes), vendors, blog, homepage content, customers/testimonials, certifications, media library, page SEO, settings, users/roles.

All business copy, products, certificates, countries and contact details are database-driven.

## Parallax

Hero, about, manufacturing and CTA sections use layered `data-speed` movement (background ~0.15×, mid ~0.35×, copy ~0.7×). Intensity is reduced on mobile and disabled when `prefers-reduced-motion` is set.

## Switch to PostgreSQL

`prisma/schema.prisma` is the relational model for production. Point `src/lib/prisma.ts` at `@prisma/client` (or generate a client) and set:

```
DATABASE_URL="postgresql://user:password@localhost:5432/helvix?schema=public"
```

Then `npx prisma db push && npx tsx prisma/seed.ts`. The rest of the app does not change — pages already go through the `prisma` data access layer.

## Environment

See `.env.example`. `AUTH_SECRET` must be a long random string in production. Put the site behind HTTPS. Uploads are type- and size-validated. Enquiry endpoints are rate-limited and include a honeypot.

## Go live (GitHub → public website)

GitHub stores the code. A host like **Vercel** turns that GitHub repo into a public URL.

### 1. Push this project to GitHub

This repo branch: `arena/019ff746-internship-tasks`

After it is merged to `main` (or from the branch itself):

1. Open [https://github.com/linux113/Internship_Tasks](https://github.com/linux113/Internship_Tasks)
2. Confirm the `helvix-industrial/` folder is there

### 2. Deploy on Vercel (recommended — free)

1. Go to [https://vercel.com/new](https://vercel.com/new)
2. Sign in with **GitHub**
3. Import **linux113/Internship_Tasks**
4. Set **Root Directory** to `helvix-industrial`
5. Add environment variables:

| Name | Value |
| --- | --- |
| `AUTH_SECRET` | any long random string |
| `NEXT_PUBLIC_SITE_URL` | your Vercel URL, e.g. `https://helvix-industrial.vercel.app` |

6. Click **Deploy**

You get a live link like:

`https://helvix-industrial.vercel.app`

Admin: `https://helvix-industrial.vercel.app/admin`

Then change the default password in Admin → Users.

### 3. Optional custom domain

In Vercel → Project → Settings → Domains, add `www.yourcompany.com`.

## Production notes

- Point `NEXT_PUBLIC_SITE_URL` at the live domain
- Add `gaId` and `gscVerification` in Admin → Settings
- Store images/documents on object storage/CDN for scale
- Schedule database backups
- Change the bootstrap admin password immediately
