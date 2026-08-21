import { PutObjectCommand, S3Client } from "@aws-sdk/client-s3";
import { writeFile, mkdir } from "fs/promises";
import path from "path";
import crypto from "crypto";

const ALLOWED = new Set([
  "image/jpeg",
  "image/png",
  "image/webp",
  "image/avif",
  "application/pdf",
]);
const MAX_BYTES = 8 * 1024 * 1024;

function extensionFor(file: File) {
  const expected: Record<string, string> = {
    "image/jpeg": "jpg",
    "image/png": "png",
    "image/webp": "webp",
    "image/avif": "avif",
    "application/pdf": "pdf",
  };
  return expected[file.type];
}

function validate(file: File) {
  if (!ALLOWED.has(file.type)) throw new Error("Unsupported file type");
  if (file.size > MAX_BYTES) throw new Error("File too large (maximum 8 MB)");
  const extension = extensionFor(file);
  if (!extension) throw new Error("Invalid file extension");
  return extension;
}

function r2Configured() {
  return Boolean(
    process.env.R2_ACCOUNT_ID &&
      process.env.R2_ACCESS_KEY_ID &&
      process.env.R2_SECRET_ACCESS_KEY &&
      process.env.R2_BUCKET_NAME &&
      process.env.R2_PUBLIC_URL,
  );
}

/**
 * Validates and stores media. Production uses private credentials server-side
 * against Cloudflare R2; local disk is a development-only fallback.
 */
export async function saveUpload(file: File | null, folder = "uploads") {
  if (!file || file.size === 0) return "";
  const extension = validate(file);
  const key = `${folder}/${new Date().toISOString().slice(0, 10)}/${crypto.randomUUID()}.${extension}`;
  const body = Buffer.from(await file.arrayBuffer());

  if (r2Configured()) {
    const client = new S3Client({
      region: "auto",
      endpoint: `https://${process.env.R2_ACCOUNT_ID}.r2.cloudflarestorage.com`,
      credentials: {
        accessKeyId: process.env.R2_ACCESS_KEY_ID!,
        secretAccessKey: process.env.R2_SECRET_ACCESS_KEY!,
      },
    });
    await client.send(
      new PutObjectCommand({
        Bucket: process.env.R2_BUCKET_NAME!,
        Key: key,
        Body: body,
        ContentType: file.type,
        CacheControl: "public, max-age=31536000, immutable",
      }),
    );
    return `${process.env.R2_PUBLIC_URL!.replace(/\/$/, "")}/${key}`;
  }

  if (process.env.NODE_ENV === "production") {
    throw new Error("Media storage is not configured");
  }
  const target = path.join(process.cwd(), "public", key);
  await mkdir(path.dirname(target), { recursive: true });
  await writeFile(target, body);
  return `/${key}`;
}
