import { redirect } from "next/navigation";
export default async function BlogAlias({ params }: { params: Promise<{ slug: string }> }) { const { slug } = await params; redirect(`/blog/${slug}`); }
