import { PrismaClient } from "@prisma/client";
import { prisma as developmentStore } from "./file-db";

/**
 * PostgreSQL is the production source of truth. The checked-in JSON adapter is
 * used only when DATABASE_URL is absent so reviewers can run the complete CMS
 * without provisioning infrastructure first.
 */
const usePostgres = process.env.DATABASE_URL?.startsWith("postgresql://") ||
  process.env.DATABASE_URL?.startsWith("postgres://");

const globalForPrisma = globalThis as unknown as { sriyaanPrisma?: PrismaClient };
const postgresClient = usePostgres
  ? globalForPrisma.sriyaanPrisma || new PrismaClient()
  : null;

if (process.env.NODE_ENV !== "production" && postgresClient) {
  globalForPrisma.sriyaanPrisma = postgresClient;
}

// Both implementations expose the Prisma operations consumed by the app.
// The cast keeps the lightweight development adapter's permissive query shape.
export const prisma = (postgresClient || developmentStore) as typeof developmentStore;
