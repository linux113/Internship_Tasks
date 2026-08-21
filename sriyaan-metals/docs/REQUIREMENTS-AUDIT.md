# Requirements traceability and implementation audit

| Client requirement | New-project baseline | Production next step |
| --- | --- | --- |
| Admin panel | Protected custom dashboard and PostgreSQL content model | Persistent CRUD, roles, audit history and media picker |
| Hero / CTA | Premium industrial hero and RFQ/product CTAs | Replace representative hero with approved brand photography if desired |
| Parallax / motion | GSAP reveal system, reduced-motion support | Add restrained section parallax after device performance QA |
| Product categories | Eight scalable category entry points | Populate complete approved catalogue |
| Product pages | Technical matrix and product-context RFQ/WhatsApp | DB-backed gallery, drawings, datasheets and related products |
| About / Why choose | Dedicated company narrative and four value pillars | Add verified history, capabilities and numbers |
| Quality / certifications | Quality approach page and inspection story | Upload only verified certificates and procedures |
| Manufacturing | Infrastructure/capability story | Replace representative image with real facility imagery |
| Industries | Eight industry groups | Add approved application case studies |
| Global reach | Export-focused content | Add verified countries, flags/map and shipment claims |
| Import/export | Dedicated trade-capability content | Add approved terms, documentation and logistics scope |
| Customers | Data model/admin scope defined | Add logos/testimonials only with permission |
| Vendor page | Supplier registration form | Persist vendor records and attach documents |
| Blog | SEO-ready knowledge centre route | Database editor, categories, authors and published articles |
| Contact | Verified address, phones, hours and department emails | Add approved Google Maps embed and social URLs |
| WhatsApp | Floating and product-specific click-to-chat | Confirm preferred default of the two numbers |
| SEO | Metadata, canonical, Organization schema, sitemap and robots | Add DB product/blog/category entries and Search Console |
| Responsive | 375px-first responsive components | Device/browser QA with final content |
| Performance | Server-rendered pages, `next/image`, local fonts, 1.1 MB source imagery | Production Lighthouse and Core Web Vitals monitoring |
| Security | Protected admin, HTTP-only cookie, production secret guard, validation, honeypot, rate limit, security headers and clean audit | Durable rate limit, CSP, password reset/MFA option, authorized Strix test |
| Backup/scalability | Indexed PostgreSQL schema and object-storage environment contract | Managed Postgres backups, R2 versioning and restore drill |

## Delivery phases

### Phase 1 — completed baseline
New Next.js project, brand/content foundation, premium public UI, responsive catalogue and details, forms, WhatsApp, technical SEO, protected admin UI, data model, security headers and documentation.

### Phase 2 — production CMS
PostgreSQL migrations, full admin CRUD, R2/S3 uploads, roles, enquiry/vendor persistence, email notifications, media management and blog editor.

### Phase 3 — verified content and launch
Real logo/brand kit, product/factory media, catalogue import, certifications, customer permissions, export markets, maps/social links, policies, analytics, QA, backups and deployment.

### Phase 4 — growth
Faceted search, bulk import/export, CRM/ERP integration, multilingual markets, approval workflows, saved RFQs and customer portal.
