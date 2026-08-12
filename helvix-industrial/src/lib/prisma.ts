import { existsSync, mkdirSync, readFileSync, statSync, writeFileSync } from "fs";
import path from "path";

export type Row = Record<string, unknown> & { id?: string };

type DB = Record<string, Row[]>;

const DB_PATH = path.join(process.cwd(), "data", "db.json");

const RELATIONS: Record<string, Record<string, { table: string; type: "one" | "many"; fk: string; local?: string }>> = {
  products: {
    category: { table: "categories", type: "one", fk: "categoryId" },
    subcategory: { table: "subcategories", type: "one", fk: "subcategoryId" },
    images: { table: "productImages", type: "many", fk: "productId" },
    documents: { table: "productDocuments", type: "many", fk: "productId" },
  },
  categories: {
    subcategories: { table: "subcategories", type: "many", fk: "categoryId" },
    products: { table: "products", type: "many", fk: "categoryId" },
  },
  blogs: {
    category: { table: "blogCategories", type: "one", fk: "categoryId" },
    author: { table: "blogAuthors", type: "one", fk: "authorId" },
  },
  enquiries: {
    product: { table: "products", type: "one", fk: "productId" },
  },
};

const EMPTY: DB = {
  users: [],
  categories: [],
  subcategories: [],
  products: [],
  productImages: [],
  productDocuments: [],
  enquiries: [],
  vendors: [],
  blogCategories: [],
  blogAuthors: [],
  blogs: [],
  customers: [],
  testimonials: [],
  certifications: [],
  industries: [],
  countries: [],
  whyChooses: [],
  infrastructureImages: [],
  homepages: [],
  pageContents: [],
  settings: [],
  mediaAssets: [],
  pageViews: [],
};

const MODEL_TABLE: Record<string, string> = {
  user: "users",
  category: "categories",
  subcategory: "subcategories",
  product: "products",
  productImage: "productImages",
  productDocument: "productDocuments",
  enquiry: "enquiries",
  vendor: "vendors",
  blogCategory: "blogCategories",
  blogAuthor: "blogAuthors",
  blog: "blogs",
  customer: "customers",
  testimonial: "testimonials",
  certification: "certifications",
  industry: "industries",
  country: "countries",
  whyChoose: "whyChooses",
  infrastructureImage: "infrastructureImages",
  homepage: "homepages",
  pageContent: "pageContents",
  setting: "settings",
  mediaAsset: "mediaAssets",
  pageView: "pageViews",
};

let cache: DB | null = null;
let cacheMtime = 0;

function hydrateDates(value: unknown): unknown {
  if (Array.isArray(value)) return value.map(hydrateDates);
  if (value && typeof value === "object") {
    const out: Record<string, unknown> = {};
    for (const [k, v] of Object.entries(value as Record<string, unknown>)) {
      if (
        typeof v === "string" &&
        /^\d{4}-\d{2}-\d{2}T/.test(v) &&
        (k.endsWith("At") || k === "publishedAt")
      ) {
        out[k] = new Date(v);
      } else {
        out[k] = hydrateDates(v);
      }
    }
    return out;
  }
  return value;
}

function readDB(): DB {
  try {
    // Avoid serving stale CMS data during a request.
    // eslint-disable-next-line @typescript-eslint/no-require-imports
    const { unstable_noStore } = require("next/cache") as {
      unstable_noStore?: () => void;
    };
    unstable_noStore?.();
  } catch {
    /* seed / scripts */
  }
  if (existsSync(DB_PATH)) {
    const mtime = statSync(DB_PATH).mtimeMs;
    if (cache && mtime === cacheMtime) return cache;
    cache = { ...structuredClone(EMPTY), ...JSON.parse(readFileSync(DB_PATH, "utf8")) };
    cacheMtime = mtime;
    return cache;
  }
  mkdirSync(path.dirname(DB_PATH), { recursive: true });
  writeFileSync(DB_PATH, JSON.stringify(EMPTY, null, 2));
  cache = structuredClone(EMPTY);
  cacheMtime = statSync(DB_PATH).mtimeMs;
  return cache;
}

function writeDB(db: DB) {
  cache = db;
  mkdirSync(path.dirname(DB_PATH), { recursive: true });
  writeFileSync(DB_PATH, JSON.stringify(db, null, 2));
  cacheMtime = statSync(DB_PATH).mtimeMs;
}

function id() {
  return `c${Date.now().toString(36)}${Math.random().toString(36).slice(2, 10)}`;
}

function matchWhere(row: Row, where?: Record<string, unknown>, db?: DB): boolean {
  if (!where) return true;
  if (where.AND && Array.isArray(where.AND)) {
    return (where.AND as Record<string, unknown>[]).every((part) => matchWhere(row, part, db));
  }
  if (where.OR && Array.isArray(where.OR)) {
    return (where.OR as Record<string, unknown>[]).some((part) => matchWhere(row, part, db));
  }
  return Object.entries(where).every(([key, value]) => {
    if (key === "AND" || key === "OR") return true;
    if (value && typeof value === "object" && !Array.isArray(value)) {
      const cond = value as Record<string, unknown>;
      if ("contains" in cond) {
        return String(row[key] ?? "")
          .toLowerCase()
          .includes(String(cond.contains).toLowerCase());
      }
      if ("not" in cond) return row[key] !== cond.not;
      if ("slug" in cond || "name" in cond) {
        const relatedId = row[`${key}Id`];
        const tableGuess = MODEL_TABLE[key] || `${key}s`;
        const table = db?.[tableGuess] || [];
        const related = table.find((r) => r.id === relatedId);
        return related ? matchWhere(related, cond, db) : false;
      }
    }
    return row[key] === value;
  });
}

function sortRows(rows: Row[], orderBy?: Record<string, string>) {
  if (!orderBy) return rows;
  const [key, dir] = Object.entries(orderBy)[0];
  return [...rows].sort((a, b) => {
    const av = a[key] as string | number | Date;
    const bv = b[key] as string | number | Date;
    if (av == null) return 1;
    if (bv == null) return -1;
    if (av < bv) return dir === "asc" ? -1 : 1;
    if (av > bv) return dir === "asc" ? 1 : -1;
    return 0;
  });
}

function pick(row: Row, select?: Record<string, unknown>) {
  if (!select) return row;
  const out: Row = {};
  for (const [k, v] of Object.entries(select)) {
    if (v) out[k] = row[k];
  }
  return out;
}

function applyInclude(table: string, row: Row, include: Record<string, unknown> | undefined, db: DB): Row {
  if (!include) return { ...row };
  const out: Row = { ...row };
  const rels = RELATIONS[table] || {};
  for (const [key, spec] of Object.entries(include)) {
    if (!spec) continue;
    if (key === "_count" && typeof spec === "object") {
      const select = (spec as { select?: Record<string, boolean> }).select || {};
      const counts: Record<string, number> = {};
      for (const field of Object.keys(select)) {
        const rel = rels[field];
        if (!rel) continue;
        counts[field] = (db[rel.table] || []).filter((r) => r[rel.fk] === row.id).length;
      }
      out._count = counts;
      continue;
    }
    const rel = rels[key];
    if (!rel) continue;
    if (rel.type === "one") {
      const found = (db[rel.table] || []).find((r) => r.id === row[rel.fk]);
      out[key] = found ? hydrateDates({ ...found }) : null;
    } else {
      let list = (db[rel.table] || []).filter((r) => r[rel.fk] === row.id);
      if (typeof spec === "object" && spec && "orderBy" in (spec as object)) {
        list = sortRows(list, (spec as { orderBy: Record<string, string> }).orderBy);
      }
      if (typeof spec === "object" && spec && "take" in (spec as object)) {
        list = list.slice(0, Number((spec as { take: number }).take));
      }
      out[key] = list.map((r) => hydrateDates({ ...r }));
    }
  }
  return out;
}

function uniqueWhere(row: Row, where: Record<string, unknown>) {
  return Object.entries(where).every(([k, v]) => row[k] === v);
}

function createModel(table: string) {
  return {
    async findMany(args: {
      where?: Record<string, unknown>;
      include?: Record<string, unknown>;
      orderBy?: Record<string, string>;
      take?: number;
      skip?: number;
      select?: Record<string, unknown>;
    } = {}) {
      const db = readDB();
      let rows = (db[table] || []).filter((r) => matchWhere(r, args.where, db));
      rows = sortRows(rows, args.orderBy);
      if (args.skip) rows = rows.slice(args.skip);
      if (args.take) rows = rows.slice(0, args.take);
      return rows.map((r) =>
        hydrateDates(pick(applyInclude(table, r, args.include, db), args.select)),
      );
    },
    async findUnique(args: { where: Record<string, unknown>; include?: Record<string, unknown> }) {
      const db = readDB();
      const row = (db[table] || []).find((r) => uniqueWhere(r, args.where));
      if (!row) return null;
      return hydrateDates(applyInclude(table, row, args.include, db));
    },
    async create(args: { data: Row }) {
      const db = readDB();
      const now = new Date().toISOString();
      const row: Row = {
        id: (args.data.id as string) || id(),
        createdAt: now,
        updatedAt: now,
        publishedAt: now,
        published: true,
        active: true,
        ...args.data,
      };
      db[table] = [...(db[table] || []), row];
      writeDB(db);
      return hydrateDates({ ...row });
    },
    async createMany(args: { data: Row[] }) {
      const db = readDB();
      const now = new Date().toISOString();
      const rows = args.data.map((d) => ({
        id: (d.id as string) || id(),
        createdAt: now,
        updatedAt: now,
        publishedAt: now,
        published: true,
        active: true,
        ...d,
      }));
      db[table] = [...(db[table] || []), ...rows];
      writeDB(db);
      return { count: rows.length };
    },
    async update(args: { where: Record<string, unknown>; data: Row }) {
      const db = readDB();
      const idx = (db[table] || []).findIndex((r) => uniqueWhere(r, args.where));
      if (idx < 0) throw new Error(`Record not found in ${table}`);
      const next = {
        ...db[table][idx],
        ...args.data,
        updatedAt: new Date().toISOString(),
      };
      db[table][idx] = next;
      writeDB(db);
      return hydrateDates({ ...next });
    },
    async upsert(args: { where: Record<string, unknown>; update: Row; create: Row }) {
      const db = readDB();
      const existing = (db[table] || []).find((r) => uniqueWhere(r, args.where));
      if (existing) return this.update({ where: args.where, data: args.update });
      return this.create({ data: { ...args.where, ...args.create } });
    },
    async delete(args: { where: Record<string, unknown> }) {
      const db = readDB();
      const row = (db[table] || []).find((r) => uniqueWhere(r, args.where));
      db[table] = (db[table] || []).filter((r) => !uniqueWhere(r, args.where));
      writeDB(db);
      return row || null;
    },
    async deleteMany(args: { where?: Record<string, unknown> } = {}) {
      const db = readDB();
      const before = (db[table] || []).length;
      db[table] = (db[table] || []).filter((r) => !matchWhere(r, args.where, db));
      writeDB(db);
      return { count: before - db[table].length };
    },
    async count(args: { where?: Record<string, unknown> } = {}) {
      const db = readDB();
      return (db[table] || []).filter((r) => matchWhere(r, args.where, db)).length;
    },
  };
}

export const prisma = {
  user: createModel("users"),
  category: createModel("categories"),
  subcategory: createModel("subcategories"),
  product: createModel("products"),
  productImage: createModel("productImages"),
  productDocument: createModel("productDocuments"),
  enquiry: createModel("enquiries"),
  vendor: createModel("vendors"),
  blogCategory: createModel("blogCategories"),
  blogAuthor: createModel("blogAuthors"),
  blog: createModel("blogs"),
  customer: createModel("customers"),
  testimonial: createModel("testimonials"),
  certification: createModel("certifications"),
  industry: createModel("industries"),
  country: createModel("countries"),
  whyChoose: createModel("whyChooses"),
  infrastructureImage: createModel("infrastructureImages"),
  homepage: createModel("homepages"),
  pageContent: createModel("pageContents"),
  setting: createModel("settings"),
  mediaAsset: createModel("mediaAssets"),
  pageView: createModel("pageViews"),
  async $disconnect() {
    return;
  },
};
