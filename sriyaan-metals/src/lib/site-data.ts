export const company = {
  name: "Sriyaan Metals",
  legalName: "SRIYAAN METALS",
  gst: "27CRKPS0693G1ZB",
  domain: "https://sriyaanmetals.com",
  email: "info@sriyaanmetals.co",
  emails: {
    sales: "sales@sriyaanmetals.co",
    purchase: "purchase@sriyaanmetals.co",
    accounts: "accounts@sriyaanmetals.co",
  },
  phones: ["+91 96195 61657", "+91 98190 33982"],
  whatsapp: "919619561657",
  address:
    "Floor 2, 204, Plot No. 96/98, Platinum Arcade, JSS Road, Central Plaza Cinema, Charni Road, Opera House, Mumbai 400004, Maharashtra, India",
  hours: "Monday–Saturday · 10:00–19:00 IST",
};

export const categories = [
  { slug: "bolts", name: "Industrial Bolts", code: "01", description: "Hex, structural, high-tensile and special bolts to international standards." },
  { slug: "nuts", name: "Precision Nuts", code: "02", description: "Hex, lock, flange, heavy and custom nuts across materials and grades." },
  { slug: "washers", name: "Washers", code: "03", description: "Plain, spring, hardened, structural and special-profile washers." },
  { slug: "screws", name: "Industrial Screws", code: "04", description: "Machine, socket, self-tapping and application-specific screws." },
  { slug: "threaded-rods", name: "Threaded Rods", code: "05", description: "Metric and imperial threaded bars, studs and cut-length assemblies." },
  { slug: "anchors", name: "Anchoring Systems", code: "06", description: "Mechanical, chemical and foundation anchoring solutions." },
  { slug: "special-fasteners", name: "Special Fasteners", code: "07", description: "Drawing-based parts, non-standard dimensions and engineered supply." },
  { slug: "stainless-steel", name: "Stainless Range", code: "08", description: "Corrosion-resistant fasteners for marine, process and exterior use." },
];

export const products = [
  { slug: "high-tensile-hex-bolts", category: "bolts", name: "High Tensile Hex Bolts", standard: "DIN 931 / DIN 933", material: "Carbon & alloy steel", grade: "8.8 / 10.9 / 12.9", sizes: "M6–M64", finish: "Plain / Zinc / HDG", applications: "Steel structures, machinery, infrastructure" },
  { slug: "structural-bolting-assemblies", category: "bolts", name: "Structural Bolting Assemblies", standard: "ASTM F3125 / EN 14399", material: "High-strength alloy steel", grade: "A325 / A490", sizes: "M12–M36", finish: "Black / HDG", applications: "Bridges, PEB, heavy steel construction" },
  { slug: "stainless-steel-hex-nuts", category: "nuts", name: "Stainless Steel Hex Nuts", standard: "DIN 934 / ISO 4032", material: "Stainless steel", grade: "A2-70 / A4-80", sizes: "M3–M48", finish: "Passivated", applications: "Marine, food, chemical and exterior systems" },
  { slug: "hardened-plain-washers", category: "washers", name: "Hardened Plain Washers", standard: "DIN 125 / ASTM F436", material: "Carbon steel", grade: "Hardened", sizes: "M6–M72", finish: "Plain / Zinc / HDG", applications: "Structural joints and high-load assemblies" },
  { slug: "socket-head-cap-screws", category: "screws", name: "Socket Head Cap Screws", standard: "DIN 912 / ISO 4762", material: "Alloy steel / stainless", grade: "12.9 / A2 / A4", sizes: "M3–M36", finish: "Black / Zinc / Passivated", applications: "Tooling, machinery and precision assemblies" },
  { slug: "fully-threaded-rods", category: "threaded-rods", name: "Fully Threaded Rods", standard: "DIN 975 / ASTM A193", material: "Carbon, alloy & stainless", grade: "4.8–10.9 / B7 / B8", sizes: "M6–M64", finish: "Plain / Zinc / HDG", applications: "MEP, process plants and structural supports" },
];

export const industries = ["Construction & Infrastructure", "Automotive", "General Engineering", "Oil & Gas", "Power & Energy", "Railways", "Heavy Machinery", "Fabrication & EPC"];

export const standards = ["ISO", "DIN", "ASTM", "BS", "EN", "IS"];

export const nav = [
  ["Products", "/products"], ["About", "/about"], ["Quality", "/quality"],
  ["Infrastructure", "/infrastructure"], ["Industries", "/industries"],
  ["Global Reach", "/global-reach"], ["Blog", "/blog"], ["Contact", "/contact"],
] as const;

export const pageContent: Record<string, { eyebrow: string; title: string; intro: string; body: string[] }> = {
  about: { eyebrow: "Company", title: "An accountable source for industrial fasteners", intro: "Sriyaan Metals supports procurement teams with specification-led sourcing, responsive service and disciplined order execution.", body: ["From our Mumbai office, we coordinate standard and special fastener requirements for manufacturers, contractors, OEMs, distributors and project buyers.", "Our role goes beyond supplying a part number. We help align standards, materials, grades, finishes, documents, inspection and logistics with the application and delivery plan."] },
  quality: { eyebrow: "Quality assurance", title: "Confidence built into every order", intro: "Product conformity begins with a clear specification and continues through supplier control, inspection, traceability and documentation.", body: ["Inspection and documentation requirements are agreed at quotation stage. Depending on the product and order, support can include dimensional records, material test certificates, coating reports and third-party inspection coordination.", "Certification claims and customer-specific approvals are published only after verification."] },
  infrastructure: { eyebrow: "Supply capability", title: "From requirement to packed dispatch", intro: "A coordinated network for sourcing, manufacturing support, inspection, warehousing, packing and dispatch.", body: ["Sriyaan Metals works across standard catalogue supply and drawing-based requirements, selecting the right route for quantity, specification, lead time and documentation.", "Real facility, machinery and warehouse photography will replace representative launch visuals once supplied by the client."] },
  industries: { eyebrow: "Applications", title: "Fasteners for demanding industries", intro: "A broad product range serving construction, automotive, engineering, infrastructure and industrial equipment.", body: ["Product selection is driven by load, environment, joint design, installation method and governing standard.", "Share a bill of materials, standard or drawing for a product-specific recommendation and quotation."] },
  "global-reach": { eyebrow: "International business", title: "Export-ready supply from India", intro: "Commercial, documentation, inspection, packing and logistics support for international orders.", body: ["We support enquiries from importers, distributors, contractors and OEMs with clear product identification and export-focused communication.", "Final export markets and verified shipment claims will be added after client approval."] },
  "import-export": { eyebrow: "Trade capability", title: "Disciplined sourcing. Dependable export support.", intro: "Domestic and international supply routes coordinated around specification, quality and delivery.", body: ["Sourcing requirements are reviewed against technical and commercial criteria before supplier selection.", "Export support can include buyer documentation, inspection coordination, export packing and shipment planning according to the agreed order terms."] },
  blog: { eyebrow: "Knowledge centre", title: "Fastener knowledge for better decisions", intro: "Practical guides on standards, materials, finishes, applications and industrial procurement.", body: ["Technical and SEO-focused articles will be managed through the content system.", "Initial topics include grade selection, coating comparison, structural fasteners, stainless steel and drawing-based procurement."] },
};
