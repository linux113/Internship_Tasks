import { writeFile, mkdir } from "fs/promises";
import path from "path";

const ALLOWED = new Set([
  "image/jpeg",
  "image/png",
  "image/webp",
  "image/avif",
  "application/pdf",
]);

export async function saveUpload(file: File | null, folder = "uploads") {
  if (!file || file.size === 0) return "";
  if (!ALLOWED.has(file.type)) {
    throw new Error("Unsupported file type");
  }
  if (file.size > 8 * 1024 * 1024) {
    throw new Error("File too large (max 8MB)");
  }
  const ext = file.name.split(".").pop()?.toLowerCase() || "bin";
  const safe = `${Date.now()}-${Math.random().toString(36).slice(2, 8)}.${ext}`;
  const dir = path.join(process.cwd(), "public", folder);
  await mkdir(dir, { recursive: true });
  const buf = Buffer.from(await file.arrayBuffer());
  await writeFile(path.join(dir, safe), buf);
  return `/${folder}/${safe}`;
}
