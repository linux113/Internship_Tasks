import { readdir } from "fs/promises";
import path from "path";

export default async function AdminMedia() {
  const root = path.join(process.cwd(), "public", "images");
  async function walk(dir: string, acc: string[] = []): Promise<string[]> {
    const entries = await readdir(dir, { withFileTypes: true });
    for (const e of entries) {
      const p = path.join(dir, e.name);
      if (e.isDirectory()) await walk(p, acc);
      else acc.push(p.replace(path.join(process.cwd(), "public"), ""));
    }
    return acc;
  }
  const files = await walk(root);

  return (
    <div>
      <h1 className="display text-4xl">Media library</h1>
      <p className="text-mist mt-2">Images currently on the public disk. Upload via product/content fields or /public/uploads.</p>
      <div className="mt-8 grid grid-cols-2 md:grid-cols-4 lg:grid-cols-6 gap-3">
        {files
          .filter((f) => /\.(jpg|jpeg|png|webp|svg)$/i.test(f))
          .slice(0, 80)
          .map((f) => (
            <figure key={f} className="border border-white/10 p-2">
              <img src={f} alt="" className="aspect-square object-cover w-full" />
              <figcaption className="mt-2 text-[10px] text-mist break-all">{f}</figcaption>
            </figure>
          ))}
      </div>
    </div>
  );
}
