# Sriyaan Metals website and CMS — PRD

## Vision
A premium B2B sales platform where procurement teams can establish trust, find a fastener by specification, and send a contextual RFQ quickly. Sriyaan staff must manage catalogue, categories, media, content, certifications, customers, blogs, vendors and enquiries without developer help.

## Verified business information
- Brand: SRIYAAN METALS
- Domain: sriyaanmetals.com
- GST: 27CRKPS0693G1ZB
- Address: Floor 2, 204, Plot No. 96/98, Platinum Arcade, JSS Road, Central Plaza Cinema, Charni Road, Opera House, Mumbai 400004
- Phones/WhatsApp: 9619561657 / 9819033982
- Hours: 10:00–19:00
- Email: info@sriyaanmetals.co
- Departments: sales@, purchase@ and accounts@sriyaanmetals.co

## Users
Procurement buyers, engineers, contractors, OEMs, importers/distributors, prospective vendors and internal administrators.

## Public scope
Homepage; catalogue and product details; About; Why Choose Us; Quality; Infrastructure; Industries; Global Reach; Import/Export; Customers; Vendor registration; Blog; Contact; Quote; WhatsApp; social links; SEO metadata/schema/sitemap/robots; responsive and reduced-motion support.

## Product information
Name, SKU, category/subcategory, images, description, standard, material, grade, size/diameter/length, finish, thread/head type, applications, availability, documents, featured/published state and SEO fields.

## Admin scope
Role-based authentication and CRUD for products/categories, media, content/blog, customers/testimonials, certifications, enquiries, vendors, SEO/settings and users. Dashboard highlights lead and catalogue status.

## Technical architecture
Next.js + TypeScript + Tailwind; Next APIs; PostgreSQL + Prisma; R2/S3-compatible storage; Vercel/Cloudflare; Zod validation; secure cookie admin session; transactional enquiry email; Google Analytics/Search Console.

## Security and operations
HTTPS, strong secret, bcrypt admin passwords, login throttling, authorization on every mutation, CSRF-aware same-site cookies, validation/honeypot/rate limits, MIME/size checks, CSP/security headers, dependency monitoring, daily database backup, object versioning and quarterly restore tests.

## Production blockers
1. Provision PostgreSQL and run Prisma migration.
2. Implement persistent catalogue/admin CRUD against the database.
3. Connect R2/S3 uploads and transactional email.
4. Add verified company history, factory/product photography, certifications, export countries, customer permissions and social URLs.
5. Configure production secrets, domain, analytics, monitoring and backups.
6. Complete WCAG, browser, mobile, Lighthouse and authorized security QA.

## Acceptance criteria
All routes work at 375–1440 px; product enquiries preserve context; WhatsApp links are correct; metadata/schema/sitemap use the canonical domain; admin is protected; forms reject invalid/spam submissions; lint/build/audit pass; no secrets are committed; production does not rely on ephemeral files.
