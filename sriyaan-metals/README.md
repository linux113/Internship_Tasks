# SRIYAAN METALS

A dynamic, enquiry-led industrial B2B website and custom CMS for **SRIYAAN METALS**.

The project is a Next.js App Router application with a PostgreSQL/Prisma production data layer, protected admin routes, product and content management, enquiry workflows, R2 media storage, SMTP notifications, structured SEO and a responsive industrial design system.

## Architecture

```text
Browser
  ├─ Public website (React Server Components)
  ├─ Enquiry / vendor forms
  └─ Protected admin CMS
          ↓
Next.js App Router
  ├─ Server Actions (admin mutations)
  ├─ Route Handlers (auth, enquiry, vendor, search)
  ├─ Zod validation + rate limits + honeypots
  ├─ jose secure sessions + bcrypt password hashing
  ├─ SMTP notification abstraction
  └─ R2 / S3 media abstraction
          ↓
Prisma ORM → PostgreSQL
```

Frequently changing content is data-driven. Products, categories, flexible product specifications, images, documents, blogs, industries, countries, certifications, infrastructure, customers, testimonials, homepage content, page SEO, contact details and social links can be managed without editing components.

## Technology stack

- Next.js 16, React 19, TypeScript
- Tailwind CSS 4 design tokens
- PostgreSQL + Prisma ORM
- jose sessions and bcrypt password hashing
- Zod server validation
- Cloudflare R2 / S3-compatible uploads
- Nodemailer SMTP abstraction
- GSAP motion with `prefers-reduced-motion` support
- Metadata API, dynamic sitemap, robots and JSON-LD

## Data modes

- When `DATABASE_URL` starts with `postgresql://` or `postgres://`, the app uses the generated Prisma PostgreSQL client.
- With no `DATABASE_URL`, it uses the development-only `data/db.json` adapter. This lets reviewers run every route and CMS workflow without provisioning a database. It must not be used as production storage.

The normalized production model is in `prisma/schema.prisma`; the initial PostgreSQL migration is in `prisma/migrations/20260821000000_initial/`.

## Database summary

Core models include User, Category, Subcategory, Product, ProductImage, ProductDocument, ProductSpecification, Enquiry, Vendor, Blog, BlogCategory, BlogAuthor, Industry, Certification, InfrastructureImage, Customer, Testimonial, Country, Homepage, PageContent, WebsiteContent, Setting, SocialLink, MediaAsset, ContactMessage and PageView.

Products support unique slugs/SKUs, publication state, flexible label/value specifications, galleries, documents, filters, SEO fields and canonical URLs. Foreign keys and indexes are defined for catalogue scale and common enquiry queries.

## Local development

Requires Node.js 20+.

```bash
cd sriyaan-metals
npm install
cp .env.example .env.local
# Remove DATABASE_URL from .env.local to use the included development adapter.
npm run db:seed
npm run dev
```

Open `http://localhost:3000` and `http://localhost:3000/admin/login`.

### Development admin

The development seed creates:

- Email: `admin@sriyaanmetals.co`
- Password: `ChangeMe-Sriyaan-2026!`

This fallback is for local review only. The login UI does not expose credentials. In a real environment, set `ADMIN_BOOTSTRAP_EMAIL` and a unique high-entropy `ADMIN_BOOTSTRAP_PASSWORD`, seed once, then rotate the account password.

## PostgreSQL setup

```bash
# Configure DATABASE_URL and DIRECT_URL first
npx prisma generate
npx prisma migrate deploy
npm run db:seed
```

For schema development:

```bash
npx prisma migrate dev --name describe_change
```

## Environment variables

See `.env.example` for the complete list:

- `DATABASE_URL`, `DIRECT_URL`
- `AUTH_SECRET`
- `ADMIN_BOOTSTRAP_EMAIL`, `ADMIN_BOOTSTRAP_PASSWORD`
- `R2_ACCOUNT_ID`, `R2_ACCESS_KEY_ID`, `R2_SECRET_ACCESS_KEY`, `R2_BUCKET_NAME`, `R2_PUBLIC_URL`
- `SMTP_HOST`, `SMTP_PORT`, `SMTP_USER`, `SMTP_PASSWORD`, `SMTP_FROM`
- `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_WHATSAPP_NUMBER`, `NEXT_PUBLIC_GA_ID`

Never commit `.env` or `.env.local`.

## Security controls

- HttpOnly, SameSite session cookie; Secure in production
- Passwords hashed with bcrypt cost 12
- Server-side route protection and active-user checks
- Zod form validation, upload type/size validation and randomized object keys
- Form honeypots and IP rate limiting
- Prisma parameterization in PostgreSQL mode
- Security response headers
- SMTP and R2 credentials remain server-only
- No credentials are rendered on the admin login screen

Run checks:

```bash
npm audit --omit=dev
npm run lint
npx tsc --noEmit
npm run build
```

## Production deployment (Vercel)

1. Create a managed PostgreSQL database and an R2 bucket/custom domain.
2. Add the environment variables from `.env.example` to Vercel.
3. Set the Vercel project **Root Directory** to `sriyaan-metals`.
4. Run `npx prisma migrate deploy` against the production database.
5. Run the seed once with unique bootstrap credentials.
6. Deploy and connect `sriyaanmetals.com`.
7. Configure SMTP, analytics and Search Console.
8. Replace/approve all representative industrial imagery before launch.
9. Back up PostgreSQL and configure R2 lifecycle/CORS policies.

## Client content still required

No certifications, products, customer logos, testimonials, export countries, statistics or capability claims were invented. Before launch, the client should provide and approve:

- Product categories, products, specifications, galleries and PDFs
- Company history, mission, vision and verified capabilities
- Facility/infrastructure details and original photographs
- Quality certificates and supporting PDFs
- Confirmed industries, import/export capabilities and countries
- Customer logo permissions and genuine testimonials
- Social media URLs
- Privacy/terms approval
- Final logo source artwork and approved brand palette

## Known limitations

- The checked-in industrial photographs are representative design assets, not asserted SRIYAAN METALS facilities. Replace them with approved client photography.
- In-memory rate limiting is suitable for a single instance; use Redis/KV for distributed production limits.
- Blog content uses controlled plain/rich text fields rather than a collaborative block editor.
- SMTP failures preserve the database lead and are logged; a production job queue is recommended for automatic retries.
- The local JSON adapter is review-only and does not provide database-level transactions.

## Verification result

Verified on 21 August 2026:

- Production build succeeds
- TypeScript check succeeds
- ESLint has no errors
- Public, admin, sitemap and robots routes return successfully
- Admin authentication and protected dashboard work
- General enquiry persists successfully
- Production dependency audit reports zero vulnerabilities
