import { saveProduct } from "@/app/admin/actions";

type Product = {
  id?: string;
  name?: string;
  slug?: string;
  sku?: string;
  shortDesc?: string;
  description?: string;
  categoryId?: string;
  subcategoryId?: string | null;
  material?: string;
  grade?: string;
  size?: string;
  diameter?: string;
  length?: string;
  standard?: string;
  finish?: string;
  threadType?: string;
  headType?: string;
  application?: string;
  availability?: string;
  features?: string;
  featured?: boolean;
  published?: boolean;
  seoTitle?: string;
  seoDesc?: string;
  seoKeywords?: string;
  images?: { url: string }[];
};

export function ProductForm({
  product,
  categories,
  subcategories,
}: {
  product?: Product;
  categories: { id: string; name: string }[];
  subcategories: { id: string; name: string; categoryId: string }[];
}) {
  const field = (name: string, label: string, value = "", area = false) => (
    <label className="block text-xs tracking-[0.16em] uppercase text-mist">
      {label}
      {area ? (
        <textarea name={name} defaultValue={value} className="input mt-2 min-h-28" />
      ) : (
        <input name={name} defaultValue={value} className="input mt-2" />
      )}
    </label>
  );

  return (
    <form action={saveProduct} className="grid gap-4 max-w-4xl dark-form">
      {product?.id && <input type="hidden" name="id" value={product.id} />}
      <div className="grid md:grid-cols-2 gap-4">
        {field("name", "Product name", product?.name)}
        {field("slug", "Slug", product?.slug)}
        {field("sku", "SKU", product?.sku)}
        <label className="block text-xs tracking-[0.16em] uppercase text-mist">
          Category
          <select name="categoryId" defaultValue={product?.categoryId} className="input mt-2" required>
            {categories.map((c) => (
              <option key={c.id} value={c.id}>
                {c.name}
              </option>
            ))}
          </select>
        </label>
        <label className="block text-xs tracking-[0.16em] uppercase text-mist">
          Subcategory
          <select name="subcategoryId" defaultValue={product?.subcategoryId || ""} className="input mt-2">
            <option value="">None</option>
            {subcategories.map((s) => (
              <option key={s.id} value={s.id}>
                {s.name}
              </option>
            ))}
          </select>
        </label>
        {field("imageUrl", "Image URL", product?.images?.[0]?.url)}
        {field("material", "Material", product?.material)}
        {field("grade", "Grade", product?.grade)}
        {field("size", "Size", product?.size)}
        {field("diameter", "Diameter", product?.diameter)}
        {field("length", "Length", product?.length)}
        {field("standard", "Standard", product?.standard)}
        {field("finish", "Finish", product?.finish)}
        {field("threadType", "Thread", product?.threadType)}
        {field("headType", "Head type", product?.headType)}
        {field("application", "Application", product?.application)}
        {field("availability", "Availability", product?.availability)}
      </div>
      {field("shortDesc", "Short description", product?.shortDesc, true)}
      {field("description", "Full description", product?.description, true)}
      {field("features", "Features (one per line)", product?.features, true)}
      {field("seoTitle", "SEO title", product?.seoTitle)}
      {field("seoDesc", "Meta description", product?.seoDesc, true)}
      {field("seoKeywords", "Keywords", product?.seoKeywords)}
      <div className="flex gap-6 text-sm">
        <label className="flex gap-2 items-center">
          <input type="checkbox" name="featured" defaultChecked={product?.featured} /> Featured
        </label>
        <label className="flex gap-2 items-center">
          <input type="checkbox" name="published" defaultChecked={product?.published ?? true} /> Published
        </label>
      </div>
      <button className="btn btn-primary w-fit">Save product</button>
    </form>
  );
}
