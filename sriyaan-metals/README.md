# Sriyaan Metals

New Next.js website and CMS baseline for **SRIYAAN METALS**.

```bash
npm install
npm run dev
```

- Website: `http://localhost:3000`
- Admin: `http://localhost:3000/admin`
- Development-only login: `admin@sriyaan.local` / `SriyaanAdmin2026!`

Production refuses fallback authentication. Configure `AUTH_SECRET`, `ADMIN_EMAIL` and `ADMIN_PASSWORD_HASH` using `.env.example`.

## Included

Premium responsive homepage, product catalogue/details, company/quality/infrastructure/industry/export content, contact/RFQ/vendor forms, WhatsApp, SEO metadata, Organization schema, sitemap, robots, protected admin UI baseline, PostgreSQL Prisma schema and production planning documents.

See `docs/PRD.md` and `DESIGN.md`. Persistent CMS CRUD, PostgreSQL, R2/S3, email delivery, verified client media/content and backups are explicit production-infrastructure work, not mocked as complete.
