import bcrypt from "bcryptjs";
import { prisma } from "../src/lib/prisma";

async function main() {
  await prisma.pageView.deleteMany();
  await prisma.productDocument.deleteMany();
  await prisma.productImage.deleteMany();
  await prisma.enquiry.deleteMany();
  await prisma.vendor.deleteMany();
  await prisma.product.deleteMany();
  await prisma.subcategory.deleteMany();
  await prisma.category.deleteMany();
  await prisma.blog.deleteMany();
  await prisma.blogCategory.deleteMany();
  await prisma.blogAuthor.deleteMany();
  await prisma.customer.deleteMany();
  await prisma.testimonial.deleteMany();
  await prisma.certification.deleteMany();
  await prisma.industry.deleteMany();
  await prisma.country.deleteMany();
  await prisma.whyChoose.deleteMany();
  await prisma.infrastructureImage.deleteMany();
  await prisma.homepage.deleteMany();
  await prisma.pageContent.deleteMany();
  await prisma.setting.deleteMany();
  await prisma.user.deleteMany();

  const passwordHash = await bcrypt.hash(
    process.env.ADMIN_BOOTSTRAP_PASSWORD || "HelvixAdmin2026!",
    12,
  );

  await prisma.user.createMany({
    data: [
      {
        name: "Ananya Shah",
        email: "nina.v@example.com",
        passwordHash,
        role: "SUPER_ADMIN",
        active: true,
      },
      {
        name: "Rahul Mehta",
        email: "ursula.b@example.com",
        passwordHash,
        role: "PRODUCT_MANAGER",
        active: true,
      },
      {
        name: "Priya Nair",
        email: "carol.w@example.org",
        passwordHash,
        role: "CONTENT_MANAGER",
        active: true,
      },
      {
        name: "Omar Khalid",
        email: "ivan.p@example.net",
        passwordHash,
        role: "SALES",
        active: true,
      },
    ],
  });

  const settings: Record<string, string> = {
    companyName: "Helvix Industrial",
    legalName: "Helvix Industrial Fasteners Pvt. Ltd.",
    tagline: "Precision Fasteners. Reliable Supply. Global Reach.",
    phone: "+91 79 4000 2800",
    email: "ivan.p@example.net",
    salesEmail: "tina.r@example.net",
    exportEmail: "olivia.t@example.org",
    whatsapp: "+91 98765 43210",
    officeAddress:
      "Helvix House, SG Highway, Ahmedabad, Gujarat 380054, India",
    factoryAddress:
      "Plot 42, GIDC Industrial Estate, Sanand, Ahmedabad, Gujarat 382170, India",
    hours: "Monday – Saturday, 09:00 – 18:30 IST",
    mapsEmbed:
      "https://maps.google.com/maps?q=Sanand%20GIDC%20Ahmedabad&t=&z=12&ie=UTF8&iwloc=&output=embed",
    linkedin: "https://www.linkedin.com/company/helvix-industrial",
    instagram: "https://www.instagram.com/helvixindustrial",
    facebook: "https://www.facebook.com/helvixindustrial",
    youtube: "https://www.youtube.com/@helvixindustrial",
    gaId: "",
    gscVerification: "",
    logo: "/logo.svg",
    favicon: "/favicon.ico",
  };
  await prisma.setting.createMany({
    data: Object.entries(settings).map(([key, value]) => ({ key, value })),
  });

  await prisma.homepage.create({
    data: {
      heroTitle: "Precision Fasteners.\nReliable Supply.\nGlobal Reach.",
      heroSubtitle:
        "High-quality industrial fasteners engineered for demanding applications and supplied with consistent quality, reliability and professional service.",
      heroBg: "/images/hero/hero-factory.jpg",
      heroFg: "/images/hero/hero-fasteners.jpg",
      heroCtaText: "Get a Quote",
      heroCtaUrl: "/quote",
      heroSecondaryText: "Send Enquiry",
      heroSecondaryUrl: "/contact",
      aboutTitle: "About Our Company",
      aboutBody:
        "For nearly three decades Helvix has engineered, sourced and supplied industrial fasteners to manufacturers, contractors and OEMs across forty countries. From structural bolts for infrastructure to precision fasteners for energy and heavy machinery, we combine manufacturing discipline with a global supply network.\n\nOur Sanand plant and partner facilities cover forging, CNC machining, heat treatment, coating and inspection. Every shipment is backed by material traceability, dimensional checks and the documentation international buyers expect.",
      aboutImage: "/images/about/plant.jpg",
      aboutCta: "Know More About Us",
      aboutCtaUrl: "/about",
      ctaTitle: "Specify the fastener.\nWe will engineer the supply.",
      ctaBody:
        "Share your drawings, grades and delivery window. Our applications and export teams respond with a clear commercial and technical proposal.",
      ctaButton: "Get a Quote",
      ctaUrl: "/quote",
      importBody:
        "Global sourcing through a qualified supplier network. Material and product procurement with incoming inspection, mill certificates and approved-vendor control.",
      exportBody:
        "Export documentation, ISPM packaging, third-party inspection and coordinated ocean or air freight to ports across the Americas, Europe, Middle East, Africa and Asia-Pacific.",
    },
  });

  const categories = await Promise.all(
    [
      {
        name: "Bolts",
        slug: "bolts",
        shortDesc: "Hex, heavy hex, structural and custom bolts.",
        description:
          "A complete range of industrial bolts manufactured and supplied to ISO, DIN, ASTM and IS standards for construction, machinery and energy applications.",
        image: "/images/categories/bolts.jpg",
      },
      {
        name: "Nuts",
        slug: "nuts",
        shortDesc: "Hex, heavy hex, lock and specialty nuts.",
        description:
          "Precision nuts in carbon steel, alloy steel and stainless grades with locking, prevailing-torque and structural variants.",
        image: "/images/categories/nuts.jpg",
      },
      {
        name: "Washers",
        slug: "washers",
        shortDesc: "Flat, spring, structural and hardened washers.",
        description:
          "Load-distribution and locking washers produced to tight flatness and hardness specifications.",
        image: "/images/categories/washers.jpg",
      },
      {
        name: "Screws",
        slug: "screws",
        shortDesc: "Machine, self-tapping and socket screws.",
        description:
          "Machine screws and socket products for equipment assembly, fabrication and maintenance.",
        image: "/images/categories/screws.jpg",
      },
      {
        name: "Studs",
        slug: "studs",
        shortDesc: "Double-end, tap-end and fully threaded studs.",
        description:
          "Stud bolts for flanges, pressure equipment and high-temperature service, including ASTM A193 / A194 combinations.",
        image: "/images/categories/studs.jpg",
      },
      {
        name: "Threaded Rods",
        slug: "threaded-rods",
        shortDesc: "Fully threaded bar in metric and imperial.",
        description:
          "Threaded rod and all-thread supplied in cut lengths or mill bars for hangers, anchors and fabrication.",
        image: "/images/categories/rods.jpg",
      },
      {
        name: "Anchors",
        slug: "anchors",
        shortDesc: "Wedge, sleeve and chemical anchors.",
        description:
          "Fixings for concrete and masonry used in infrastructure, plant installation and façade work.",
        image: "/images/categories/anchors.jpg",
      },
      {
        name: "Special Fasteners",
        slug: "special-fasteners",
        shortDesc: "Non-standard geometry and high-spec parts.",
        description:
          "Specials produced from drawing: odd lengths, exotic alloys, captive washers and application-specific heads.",
        image: "/images/categories/special.jpg",
      },
      {
        name: "Custom Fasteners",
        slug: "custom-fasteners",
        shortDesc: "Engineered to print, from prototype to series.",
        description:
          "Collaborative development of custom fasteners with PPAP, first-article inspection and controlled process capability.",
        image: "/images/categories/custom.jpg",
      },
    ].map((c, i) =>
      prisma.category.create({
        data: {
          ...c,
          sortOrder: i,
          seoTitle: `${c.name} | Industrial Fasteners | Helvix`,
          seoDesc: c.description,
          seoKeywords: `${c.name.toLowerCase()}, industrial ${c.name.toLowerCase()}, fastener manufacturer`,
        },
      }),
    ),
  );

  const cat = Object.fromEntries(categories.map((c) => [c.slug, c]));

  const subDefs: Array<[string, string, string]> = [
    ["bolts", "Hex Bolts", "hex-bolts"],
    ["bolts", "Heavy Hex Bolts", "heavy-hex-bolts"],
    ["bolts", "Structural Bolts", "structural-bolts"],
    ["nuts", "Hex Nuts", "hex-nuts"],
    ["nuts", "Heavy Hex Nuts", "heavy-hex-nuts"],
    ["nuts", "Lock Nuts", "lock-nuts"],
    ["washers", "Flat Washers", "flat-washers"],
    ["washers", "Spring Washers", "spring-washers"],
    ["screws", "Socket Head Cap Screws", "socket-head-cap-screws"],
    ["screws", "Machine Screws", "machine-screws"],
    ["studs", "Stud Bolts", "stud-bolts"],
    ["threaded-rods", "Fully Threaded Rods", "fully-threaded-rods"],
    ["anchors", "Wedge Anchors", "wedge-anchors"],
    ["special-fasteners", "High Temperature Fasteners", "high-temperature"],
    ["custom-fasteners", "Made to Print", "made-to-print"],
  ];

  const subs = await Promise.all(
    subDefs.map(([parent, name, slug], i) =>
      prisma.subcategory.create({
        data: {
          name,
          slug,
          categoryId: cat[parent].id,
          sortOrder: i,
        },
      }),
    ),
  );

  const sub = Object.fromEntries(subs.map((s) => [s.slug, s]));

  type P = {
    name: string;
    slug: string;
    sku: string;
    cat: string;
    sub?: string;
    short: string;
    desc: string;
    material: string;
    grade: string;
    size: string;
    diameter: string;
    length: string;
    standard: string;
    finish: string;
    thread: string;
    head: string;
    application: string;
    features: string;
    image: string;
    featured?: boolean;
  };

  const products: P[] = [
    {
      name: "ISO 4014 Hex Bolt",
      slug: "iso-4014-hex-bolt",
      sku: "HVX-B-4014",
      cat: "bolts",
      sub: "hex-bolts",
      short: "Partially threaded hex bolt for general industrial assembly.",
      desc: "ISO 4014 hex bolts produced in property classes 8.8 and 10.9 with full material traceability. Suitable for machinery frames, structural connections and plant maintenance where a proven metric hex fastener is required.",
      material: "Alloy Steel",
      grade: "8.8 / 10.9",
      size: "M6 – M64",
      diameter: "M6 – M64",
      length: "16 – 500 mm",
      standard: "ISO 4014 / DIN 931",
      finish: "Black oxide, zinc, HDG, PTFE",
      thread: "Metric coarse / fine",
      head: "Hexagon",
      application: "Machinery, fabrication, plant maintenance",
      features: "Mill test certificates\n100% thread gauge check on critical lots\nCut-to-length specials available",
      image: "/images/categories/bolts.jpg",
      featured: true,
    },
    {
      name: "ISO 4017 Fully Threaded Hex Bolt",
      slug: "iso-4017-hex-bolt",
      sku: "HVX-B-4017",
      cat: "bolts",
      sub: "hex-bolts",
      short: "Fully threaded hex bolt for jigs, fixtures and clamped joints.",
      desc: "Fully threaded ISO 4017 bolts used where grip length varies or where the full thread is required for adjustment. Supplied in carbon and stainless grades.",
      material: "Carbon Steel / Stainless",
      grade: "8.8 / A2-70 / A4-80",
      size: "M5 – M36",
      diameter: "M5 – M36",
      length: "12 – 300 mm",
      standard: "ISO 4017 / DIN 933",
      finish: "Plain, zinc, hot-dip galvanized",
      thread: "Metric coarse",
      head: "Hexagon",
      application: "Fixtures, electrical panels, general assembly",
      features: "Stainless A2 and A4 options\nBatch hardness verification",
      image: "/images/categories/bolts.jpg",
    },
    {
      name: "ASTM A325 Structural Bolt",
      slug: "astm-a325-structural-bolt",
      sku: "HVX-B-A325",
      cat: "bolts",
      sub: "structural-bolts",
      short: "Heavy hex structural bolt for steel construction.",
      desc: "ASTM A325 / F3125 Grade A325 heavy hex bolts for structural steel connections. Available as bolt-nut-washer assemblies with matching A563 nuts and F436 washers.",
      material: "Medium carbon steel",
      grade: "A325 Type 1",
      size: "1/2\" – 1-1/2\"",
      diameter: "1/2\" – 1-1/2\"",
      length: "1-1/2\" – 12\"",
      standard: "ASTM F3125 Gr. A325",
      finish: "Plain, mechanically galvanized, HDG",
      thread: "UNC",
      head: "Heavy hex",
      application: "Structural steel, bridges, industrial buildings",
      features: "Assembly sets available\nRotational capacity testing on request",
      image: "/images/categories/bolts.jpg",
      featured: true,
    },
    {
      name: "ASTM A490 High Strength Structural Bolt",
      slug: "astm-a490-structural-bolt",
      sku: "HVX-B-A490",
      cat: "bolts",
      sub: "structural-bolts",
      short: "Alloy steel structural bolt for high-strength joints.",
      desc: "A490 heavy hex bolts for connections that demand higher tensile strength than A325. Heat-treated alloy steel with controlled hardness and impact properties.",
      material: "Alloy steel",
      grade: "A490 Type 1",
      size: "5/8\" – 1-1/2\"",
      diameter: "5/8\" – 1-1/2\"",
      length: "2\" – 10\"",
      standard: "ASTM F3125 Gr. A490",
      finish: "Plain (no hot-dip galvanizing)",
      thread: "UNC",
      head: "Heavy hex",
      application: "Heavy structural steel, high-rise, industrial frames",
      features: "Charpy impact on request\nPair with A563 DH nuts",
      image: "/images/categories/bolts.jpg",
    },
    {
      name: "Heavy Hex Bolt DIN 6914",
      slug: "heavy-hex-bolt-din-6914",
      sku: "HVX-B-6914",
      cat: "bolts",
      sub: "heavy-hex-bolts",
      short: "HV heavy hex bolt for preloaded structural connections.",
      desc: "DIN 6914 / EN 14399 compatible heavy hex bolts used in HV structural assemblies with DIN 6915 nuts and 6916 washers.",
      material: "Alloy steel",
      grade: "10.9",
      size: "M12 – M36",
      diameter: "M12 – M36",
      length: "40 – 300 mm",
      standard: "DIN 6914 / EN 14399-4",
      finish: "Hot-dip galvanized, sherardized",
      thread: "Metric coarse",
      head: "Heavy hex",
      application: "European structural steelwork",
      features: "k-class documentation\nMatched assembly supply",
      image: "/images/categories/bolts.jpg",
    },
    {
      name: "ISO 4032 Hex Nut",
      slug: "iso-4032-hex-nut",
      sku: "HVX-N-4032",
      cat: "nuts",
      sub: "hex-nuts",
      short: "Standard hex nut in metric property classes.",
      desc: "ISO 4032 hex nuts manufactured to class 8 and 10, with optional stainless A2/A4. Proof-load tested by lot.",
      material: "Carbon steel / Stainless",
      grade: "8 / 10 / A2-70",
      size: "M4 – M64",
      diameter: "M4 – M64",
      length: "—",
      standard: "ISO 4032 / DIN 934",
      finish: "Plain, zinc, HDG, nickel",
      thread: "Metric coarse / fine",
      head: "Hexagon",
      application: "General industrial fastening",
      features: "Go/no-go thread inspection\nPrevailing torque variants available",
      image: "/images/categories/nuts.jpg",
      featured: true,
    },
    {
      name: "Heavy Hex Nut ASTM A563",
      slug: "heavy-hex-nut-a563",
      sku: "HVX-N-A563",
      cat: "nuts",
      sub: "heavy-hex-nuts",
      short: "Structural heavy hex nut for A325/A490 bolts.",
      desc: "A563 Grade DH and C heavy hex nuts for structural bolting assemblies. Controlled proof load and hardness.",
      material: "Carbon / alloy steel",
      grade: "A563 DH / C",
      size: "1/2\" – 1-1/2\"",
      diameter: "1/2\" – 1-1/2\"",
      length: "—",
      standard: "ASTM A563",
      finish: "Plain, HDG, mechanical zinc",
      thread: "UNC",
      head: "Heavy hex",
      application: "Structural steel connections",
      features: "Supplied as matched assemblies\nLot traceability",
      image: "/images/categories/nuts.jpg",
    },
    {
      name: "Nylon Insert Lock Nut",
      slug: "nylon-insert-lock-nut",
      sku: "HVX-N-NYL",
      cat: "nuts",
      sub: "lock-nuts",
      short: "Prevailing-torque nut with nylon insert.",
      desc: "DIN 985 / ISO 10511 style lock nuts for vibration-prone assemblies in equipment and transport.",
      material: "Steel / Stainless",
      grade: "8 / A2",
      size: "M4 – M24",
      diameter: "M4 – M24",
      length: "—",
      standard: "DIN 985",
      finish: "Zinc, plain",
      thread: "Metric coarse",
      head: "Hexagon, nylon insert",
      application: "Automotive, machinery, HVAC",
      features: "Reusable within insert life\nTemperature rated to 120°C",
      image: "/images/categories/nuts.jpg",
    },
    {
      name: "ISO 7089 Flat Washer",
      slug: "iso-7089-flat-washer",
      sku: "HVX-W-7089",
      cat: "washers",
      sub: "flat-washers",
      short: "Hardened and unhardened flat washers.",
      desc: "Through-hardened and product-grade A flat washers for load distribution under bolt heads and nuts.",
      material: "Carbon steel / Stainless",
      grade: "200 HV / 300 HV",
      size: "M5 – M64",
      diameter: "M5 – M64",
      length: "—",
      standard: "ISO 7089 / DIN 125",
      finish: "Plain, zinc, HDG",
      thread: "—",
      head: "Flat",
      application: "General and structural joints",
      features: "Tight flatness control\nStructural F436 equivalents available",
      image: "/images/categories/washers.jpg",
      featured: true,
    },
    {
      name: "Spring Lock Washer DIN 127",
      slug: "spring-lock-washer-din-127",
      sku: "HVX-W-127",
      cat: "washers",
      sub: "spring-washers",
      short: "Split spring washer for secondary locking.",
      desc: "DIN 127 B spring washers in spring steel and stainless, oil-quenched and tempered.",
      material: "Spring steel / A2",
      grade: "Spring",
      size: "M4 – M30",
      diameter: "M4 – M30",
      length: "—",
      standard: "DIN 127",
      finish: "Phosphate, zinc",
      thread: "—",
      head: "Split spring",
      application: "Electrical, machinery, maintenance",
      features: "Hardness 43–50 HRC\nPaired washer sets on request",
      image: "/images/categories/washers.jpg",
    },
    {
      name: "Socket Head Cap Screw ISO 4762",
      slug: "socket-head-cap-screw-iso-4762",
      sku: "HVX-S-4762",
      cat: "screws",
      sub: "socket-head-cap-screws",
      short: "Allen cap screw for compact, high-clamp joints.",
      desc: "ISO 4762 / DIN 912 socket head cap screws in 12.9 and stainless, used in tooling, automation and precision equipment.",
      material: "Alloy steel / Stainless",
      grade: "12.9 / A2-70 / A4-80",
      size: "M3 – M24",
      diameter: "M3 – M24",
      length: "6 – 200 mm",
      standard: "ISO 4762 / DIN 912",
      finish: "Black oxide, zinc flake",
      thread: "Metric coarse",
      head: "Cylindrical socket",
      application: "Machine tools, automation, dies",
      features: "Socket gauged\n12.9 with controlled temper",
      image: "/images/categories/screws.jpg",
      featured: true,
    },
    {
      name: "Machine Screw DIN 84 / DIN 85",
      slug: "machine-screw-din-84",
      sku: "HVX-S-MS",
      cat: "screws",
      sub: "machine-screws",
      short: "Slotted and Phillips machine screws.",
      desc: "Cheese-head and pan-head machine screws for panels, enclosures and light fabrication.",
      material: "Steel / Stainless / Brass",
      grade: "4.8 / A2",
      size: "M2 – M10",
      diameter: "M2 – M10",
      length: "4 – 80 mm",
      standard: "DIN 84 / DIN 85 / ISO 1207",
      finish: "Zinc, nickel, plain",
      thread: "Metric coarse",
      head: "Cheese / pan",
      application: "Enclosures, electronics, furniture hardware",
      features: "Cross and slotted drives\nSmall-lot packaging",
      image: "/images/categories/screws.jpg",
    },
    {
      name: "ASTM A193 B7 Stud Bolt",
      slug: "astm-a193-b7-stud-bolt",
      sku: "HVX-ST-B7",
      cat: "studs",
      sub: "stud-bolts",
      short: "B7 stud with 2H nuts for flanges and pressure equipment.",
      desc: "ASTM A193 Grade B7 stud bolts supplied with A194 Grade 2H nuts. Continuous-thread and double-end configurations for oil & gas, power and process plants.",
      material: "Chromium-molybdenum steel",
      grade: "B7 / 2H",
      size: "1/2\" – 3\"",
      diameter: "1/2\" – 3\"",
      length: "To drawing / ASME B16.5",
      standard: "ASTM A193 B7 / A194 2H",
      finish: "Plain, PTFE, zinc flake, Xylan",
      thread: "UN / 8UN",
      head: "Stud (no head)",
      application: "Flanges, valves, heat exchangers, pressure vessels",
      features: "PMI on request\n3.1 / 3.2 certification\nNACE MR0175 options",
      image: "/images/categories/studs.jpg",
      featured: true,
    },
    {
      name: "ASTM A193 B8 / B8M Stud",
      slug: "astm-a193-b8-stud",
      sku: "HVX-ST-B8",
      cat: "studs",
      sub: "stud-bolts",
      short: "Stainless stud bolts for corrosive service.",
      desc: "A193 B8 (304) and B8M (316) studs, class 1 and class 2, for chemical, marine and food-grade process connections.",
      material: "Stainless 304 / 316",
      grade: "B8 / B8M",
      size: "1/2\" – 2\"",
      diameter: "1/2\" – 2\"",
      length: "To drawing",
      standard: "ASTM A193 / A194",
      finish: "Plain, passivated",
      thread: "UN",
      head: "Stud",
      application: "Chemical, marine, water treatment",
      features: "Class 2 strain-hardened\nPair with Gr. 8 / 8M nuts",
      image: "/images/categories/studs.jpg",
    },
    {
      name: "Fully Threaded Rod DIN 975",
      slug: "fully-threaded-rod-din-975",
      sku: "HVX-R-975",
      cat: "threaded-rods",
      sub: "fully-threaded-rods",
      short: "Metric all-thread in 1 m and 3 m bars.",
      desc: "DIN 975 / 976 threaded rod in 4.8, 8.8 and stainless. Cut-to-length service with chamfered ends.",
      material: "Steel / Stainless",
      grade: "4.8 / 8.8 / A2 / A4",
      size: "M6 – M36",
      diameter: "M6 – M36",
      length: "1000 / 3000 mm or cut",
      standard: "DIN 975 / DIN 976",
      finish: "Zinc, HDG, plain",
      thread: "Metric coarse",
      head: "—",
      application: "Hangers, anchors, fabrication, formwork",
      features: "In-house cutting\nCouplers and fittings available",
      image: "/images/categories/rods.jpg",
      featured: true,
    },
    {
      name: "UNC All-Thread Rod",
      slug: "unc-all-thread-rod",
      sku: "HVX-R-UNC",
      cat: "threaded-rods",
      sub: "fully-threaded-rods",
      short: "Imperial fully threaded bar.",
      desc: "UNC and 8UN all-thread for North American construction and MRO supply programmes.",
      material: "Low carbon / B7",
      grade: "A307 / B7",
      size: "1/4\" – 2\"",
      diameter: "1/4\" – 2\"",
      length: "3 ft / 6 ft / 12 ft",
      standard: "ASTM A193 / A307",
      finish: "Plain, zinc, HDG",
      thread: "UNC / 8UN",
      head: "—",
      application: "Construction, OEM kits, MRO",
      features: "B7 high-temp option\nExport crating",
      image: "/images/categories/rods.jpg",
    },
    {
      name: "Wedge Anchor",
      slug: "wedge-anchor",
      sku: "HVX-A-WDG",
      cat: "anchors",
      sub: "wedge-anchors",
      short: "Through-fixing expansion anchor for cracked and uncracked concrete.",
      desc: "Torque-controlled wedge anchors for plant bases, racking, façade brackets and mechanical services.",
      material: "Carbon steel / Stainless A4",
      grade: "5.8 / A4-70",
      size: "M8 – M20",
      diameter: "M8 – M20",
      length: "75 – 300 mm",
      standard: "ETA / manufacturer spec",
      finish: "Zinc, HDG, stainless",
      thread: "Metric",
      head: "Hex nut & washer",
      application: "Concrete fixing, plant installation",
      features: "Setting tools available\nStainless for corrosive sites",
      image: "/images/categories/anchors.jpg",
    },
    {
      name: "Sleeve Anchor",
      slug: "sleeve-anchor",
      sku: "HVX-A-SLV",
      cat: "anchors",
      sub: "wedge-anchors",
      short: "Medium-duty sleeve anchor for masonry and concrete.",
      desc: "Versatile sleeve anchors for light-to-medium duty fixings in brick, block and concrete.",
      material: "Carbon steel",
      grade: "4.8",
      size: "M6 – M16",
      diameter: "M6 – M16",
      length: "40 – 150 mm",
      standard: "Manufacturer spec",
      finish: "Zinc",
      thread: "Metric",
      head: "Hex / countersunk",
      application: "Services, racking, light bases",
      features: "Multiple head styles\nRetail and bulk packs",
      image: "/images/categories/anchors.jpg",
    },
    {
      name: "Inconel 718 Special Fastener",
      slug: "inconel-718-special-fastener",
      sku: "HVX-SP-718",
      cat: "special-fasteners",
      sub: "high-temperature",
      short: "Nickel-alloy fastener for extreme temperature and corrosion.",
      desc: "Made-to-print fasteners in Inconel 718 and related nickel alloys for turbines, exhaust and sour-service equipment.",
      material: "Inconel 718",
      grade: "AMS 5662 / 5663",
      size: "To drawing",
      diameter: "M6 – M30 / #10 – 1\"",
      length: "To drawing",
      standard: "Customer drawing / AMS",
      finish: "Passivated, silver plate",
      thread: "UNJ / metric",
      head: "As specified",
      application: "Aerospace-adjacent, energy, high-temp process",
      features: "Full heat-treat records\nNDT on request",
      image: "/images/categories/special.jpg",
      featured: true,
    },
    {
      name: "PTFE Coated Stud Assembly",
      slug: "ptfe-coated-stud-assembly",
      sku: "HVX-SP-PTFE",
      cat: "special-fasteners",
      sub: "high-temperature",
      short: "Fluoropolymer-coated studs for corrosive atmospheres.",
      desc: "B7 / L7 studs with blue or green PTFE / Xylan coating and matching coated nuts for offshore and chemical plants.",
      material: "Alloy steel + PTFE",
      grade: "B7 / L7",
      size: "5/8\" – 2\"",
      diameter: "5/8\" – 2\"",
      length: "ASME length",
      standard: "ASTM A193 + coating spec",
      finish: "PTFE / Xylan",
      thread: "UN",
      head: "Stud",
      application: "Offshore, desalination, chemical",
      features: "Salt-spray tested coating\nColour-coded lots",
      image: "/images/categories/special.jpg",
    },
    {
      name: "Made-to-Print Custom Fastener",
      slug: "made-to-print-custom-fastener",
      sku: "HVX-CU-MTP",
      cat: "custom-fasteners",
      sub: "made-to-print",
      short: "Engineered fastener from customer drawing or sample.",
      desc: "Prototype-to-production custom fasteners. Turning, forging, grinding, coating and inspection against your print, with FAIR and PPAP when required.",
      material: "As specified",
      grade: "As specified",
      size: "Prototype to series",
      diameter: "M3 – M72",
      length: "To print",
      standard: "Customer standard",
      finish: "Any commercial finish",
      thread: "Metric / UN / special",
      head: "Any",
      application: "OEM equipment, rail, defence-adjacent industry",
      features: "PPAP / FAIR\nProcess FMEA\nDedicated project engineer",
      image: "/images/categories/custom.jpg",
      featured: true,
    },
    {
      name: "Captive Washer Assembly",
      slug: "captive-washer-assembly",
      sku: "HVX-CU-CAP",
      cat: "custom-fasteners",
      sub: "made-to-print",
      short: "Pre-assembled bolt and washer for line-side efficiency.",
      desc: "Sems and captive washer screws that reduce assembly time and lost hardware on OEM lines.",
      material: "Steel / Stainless",
      grade: "8.8 / A2",
      size: "M4 – M12",
      diameter: "M4 – M12",
      length: "10 – 80 mm",
      standard: "Customer / DIN",
      finish: "Zinc flake, zinc",
      thread: "Metric",
      head: "Hex / flange / socket",
      application: "Automotive tier, appliance, equipment OEM",
      features: "Washer retention 100% checked\nKanban packaging",
      image: "/images/categories/custom.jpg",
    },
  ];

  for (const p of products) {
    const created = await prisma.product.create({
      data: {
        name: p.name,
        slug: p.slug,
        sku: p.sku,
        shortDesc: p.short,
        description: p.desc,
        categoryId: cat[p.cat].id,
        subcategoryId: p.sub ? sub[p.sub]?.id : undefined,
        material: p.material,
        grade: p.grade,
        size: p.size,
        diameter: p.diameter,
        length: p.length,
        standard: p.standard,
        finish: p.finish,
        threadType: p.thread,
        headType: p.head,
        application: p.application,
        features: p.features,
        featured: Boolean(p.featured),
        seoTitle: `${p.name} | ${p.standard} | Helvix`,
        seoDesc: p.short,
        seoKeywords: `${p.name}, ${p.standard}, ${p.material}, industrial fastener`,
      },
    });
    await prisma.productImage.create({
      data: {
        productId: created.id,
        url: p.image,
        alt: p.name,
      },
    });
    await prisma.productDocument.createMany({
      data: [
        {
          productId: created.id,
          name: "Technical datasheet",
          url: "/documents/sample-datasheet.pdf",
          type: "datasheet",
        },
        {
          productId: created.id,
          name: "Dimensional drawing",
          url: "/documents/sample-drawing.pdf",
          type: "drawing",
        },
      ],
    });
  }

  await prisma.whyChoose.createMany({
    data: [
      {
        title: "Quality",
        description:
          "Incoming, in-process and final inspection with material certificates and dimensional reports on every critical lot.",
        icon: "shield",
        sortOrder: 0,
      },
      {
        title: "Reliability",
        description:
          "Committed lead times, professional documentation and a supply desk that stays with the order until it lands.",
        icon: "clock",
        sortOrder: 1,
      },
      {
        title: "Competitive Pricing",
        description:
          "Manufacturing plus qualified global sourcing lets us structure commercial offers for project and programme volumes.",
        icon: "scale",
        sortOrder: 2,
      },
      {
        title: "Wide Product Range",
        description:
          "Twelve thousand active SKUs across bolts, nuts, studs, anchors and specials — metric and imperial.",
        icon: "grid",
        sortOrder: 3,
      },
      {
        title: "Global Supply",
        description:
          "Export packing, third-party inspection and freight coordination to forty-plus international markets.",
        icon: "globe",
        sortOrder: 4,
      },
      {
        title: "Technical Expertise",
        description:
          "Application engineers who can read a joint, a coating spec or a flange standard and answer with a part number.",
        icon: "tool",
        sortOrder: 5,
      },
    ],
  });

  await prisma.certification.createMany({
    data: [
      {
        name: "ISO 9001:2015",
        issuer: "Quality management",
        description: "Certified quality management system covering manufacture and supply.",
        image: "/images/certs/iso9001.svg",
        sortOrder: 0,
      },
      {
        name: "ISO 14001",
        issuer: "Environmental management",
        description: "Environmental controls across coating, waste and energy use.",
        image: "/images/certs/iso14001.svg",
        sortOrder: 1,
      },
      {
        name: "EN 14399 / CE",
        issuer: "Structural fasteners",
        description: "Factory production control for preloaded structural bolting assemblies.",
        image: "/images/certs/ce.svg",
        sortOrder: 2,
      },
      {
        name: "Material 3.1 / 3.2",
        issuer: "EN 10204",
        description: "Mill certificates and third-party endorsed inspection documents.",
        image: "/images/certs/en10204.svg",
        sortOrder: 3,
      },
      {
        name: "NACE / MR0175",
        issuer: "Sour service",
        description: "Capability to supply fasteners meeting sour-service constraints.",
        image: "/images/certs/nace.svg",
        sortOrder: 4,
      },
      {
        name: "Third-party inspection",
        issuer: "TUV / BV / SGS / Lloyd's",
        description: "Open to buyer-nominated inspection at plant or warehouse.",
        image: "/images/certs/tpi.svg",
        sortOrder: 5,
      },
    ],
  });

  await prisma.infrastructureImage.createMany({
    data: [
      {
        title: "CNC machining",
        caption: "Turning and milling cells for specials and high-accuracy threads.",
        image: "/images/factory/cnc-close.jpg",
        sortOrder: 0,
      },
      {
        title: "Plant & raw material",
        caption: "Sanand campus with incoming steel and in-house processing.",
        image: "/images/hero/hero-factory.jpg",
        sortOrder: 1,
      },
      {
        title: "Finished goods",
        caption: "Batch-identified fasteners ready for export packing.",
        image: "/images/hero/hero-fasteners.jpg",
        sortOrder: 2,
      },
      {
        title: "Warehouse",
        caption: "Programme stock for OEM and distributor partners.",
        image: "/images/factory/warehouse.jpg",
        sortOrder: 3,
      },
      {
        title: "Inspection",
        caption: "Dimensional, hardness and coating verification.",
        image: "/images/factory/inspection.jpg",
        sortOrder: 4,
      },
      {
        title: "Dispatch",
        caption: "Export crating and container loading from Sanand.",
        image: "/images/factory/dispatch.jpg",
        sortOrder: 5,
      },
    ],
  });

  await prisma.industry.createMany({
    data: [
      {
        name: "Construction",
        slug: "construction",
        description:
          "Structural bolts, anchors and galvanized assemblies for buildings, plants and civil works.",
        applications: "Steel frames, precast, façade brackets, plant bases",
        image: "/images/industries/construction.jpg",
        sortOrder: 0,
      },
      {
        name: "Automotive",
        slug: "automotive",
        description:
          "High-volume fasteners and captive assemblies for vehicle and tier manufacturers.",
        applications: "Powertrain brackets, chassis, interiors, tooling",
        image: "/images/industries/automotive.jpg",
        sortOrder: 1,
      },
      {
        name: "Engineering",
        slug: "engineering",
        description:
          "Metric and imperial fasteners for general engineering and capital equipment.",
        applications: "Gearboxes, frames, maintenance kits",
        image: "/images/industries/engineering.jpg",
        sortOrder: 2,
      },
      {
        name: "Infrastructure",
        slug: "infrastructure",
        description:
          "Heavy hex and HV systems for bridges, metros and public structures.",
        applications: "Bridges, stations, transmission, ports",
        image: "/images/industries/infrastructure.jpg",
        sortOrder: 3,
      },
      {
        name: "Heavy Machinery",
        slug: "heavy-machinery",
        description:
          "Large-diameter bolts and specials for mining, earthmoving and process machines.",
        applications: "Booms, housings, wear-part joints",
        image: "/images/industries/machinery.jpg",
        sortOrder: 4,
      },
      {
        name: "Oil & Gas",
        slug: "oil-and-gas",
        description:
          "B7/L7 studs, PTFE coatings and sour-service options for upstream and downstream.",
        applications: "Flanges, Christmas trees, heat exchangers",
        image: "/images/industries/oilgas.jpg",
        sortOrder: 5,
      },
      {
        name: "Power",
        slug: "power",
        description:
          "High-temperature and high-strength fasteners for generation and T&D.",
        applications: "Turbines, boilers, switchyards",
        image: "/images/industries/power.jpg",
        sortOrder: 6,
      },
      {
        name: "Railways",
        slug: "railways",
        description:
          "Track, rolling-stock and depot fasteners to railway specifications.",
        applications: "Bogies, track fittings, depot plant",
        image: "/images/industries/railways.jpg",
        sortOrder: 7,
      },
      {
        name: "Industrial Equipment",
        slug: "industrial-equipment",
        description:
          "Socket products and engineered fasteners for OEMs of industrial equipment.",
        applications: "Pumps, compressors, packaging lines",
        image: "/images/industries/equipment.jpg",
        sortOrder: 8,
      },
      {
        name: "Fabrication",
        slug: "fabrication",
        description:
          "Everyday hex fasteners, rods and anchors for fabrication shops.",
        applications: "Skids, platforms, hoppers, mezzanines",
        image: "/images/industries/fabrication.jpg",
        sortOrder: 9,
      },
    ],
  });

  await prisma.country.createMany({
    data: [
      { name: "United States", region: "Americas", lat: 39, lng: -98, sortOrder: 0 },
      { name: "Canada", region: "Americas", lat: 56, lng: -106, sortOrder: 1 },
      { name: "Brazil", region: "Americas", lat: -10, lng: -55, sortOrder: 2 },
      { name: "United Kingdom", region: "Europe", lat: 54, lng: -2, sortOrder: 3 },
      { name: "Germany", region: "Europe", lat: 51, lng: 10, sortOrder: 4 },
      { name: "Netherlands", region: "Europe", lat: 52, lng: 5, sortOrder: 5 },
      { name: "UAE", region: "Middle East", lat: 24, lng: 54, sortOrder: 6 },
      { name: "Saudi Arabia", region: "Middle East", lat: 24, lng: 45, sortOrder: 7 },
      { name: "Qatar", region: "Middle East", lat: 25, lng: 51, sortOrder: 8 },
      { name: "South Africa", region: "Africa", lat: -29, lng: 24, sortOrder: 9 },
      { name: "Kenya", region: "Africa", lat: 0, lng: 38, sortOrder: 10 },
      { name: "India", region: "Asia", lat: 22, lng: 78, sortOrder: 11 },
      { name: "Singapore", region: "Asia Pacific", lat: 1.3, lng: 103.8, sortOrder: 12 },
      { name: "Malaysia", region: "Asia Pacific", lat: 4, lng: 102, sortOrder: 13 },
      { name: "Australia", region: "Asia Pacific", lat: -25, lng: 134, sortOrder: 14 },
      { name: "New Zealand", region: "Asia Pacific", lat: -41, lng: 174, sortOrder: 15 },
      { name: "Japan", region: "Asia Pacific", lat: 36, lng: 138, sortOrder: 16 },
      { name: "South Korea", region: "Asia Pacific", lat: 36, lng: 128, sortOrder: 17 },
    ],
  });

  await prisma.customer.createMany({
    data: [
      { name: "Nordvik Steel", logo: "/images/customers/nordvik.svg", website: "#", sortOrder: 0 },
      { name: "Apex Rail", logo: "/images/customers/apex.svg", website: "#", sortOrder: 1 },
      { name: "Gulf Petro Systems", logo: "/images/customers/gulf.svg", website: "#", sortOrder: 2 },
      { name: "Helion Power", logo: "/images/customers/helion.svg", website: "#", sortOrder: 3 },
      { name: "Mariner Fabrication", logo: "/images/customers/mariner.svg", website: "#", sortOrder: 4 },
      { name: "Voss Heavy Industries", logo: "/images/customers/voss.svg", website: "#", sortOrder: 5 },
      { name: "Sable Infrastructure", logo: "/images/customers/sable.svg", website: "#", sortOrder: 6 },
      { name: "Kite Automotive", logo: "/images/customers/kite.svg", website: "#", sortOrder: 7 },
    ],
  });

  await prisma.testimonial.createMany({
    data: [
      {
        quote:
          "Helvix treated a delayed bridge package as if it were their own critical path. Documentation was complete and the A325 assemblies landed ready for inspection.",
        name: "Daniel Crowe",
        company: "Sable Infrastructure",
        designation: "Procurement Lead",
        sortOrder: 0,
      },
      {
        quote:
          "We moved a family of socket products and a custom captive washer onto a single Helvix programme. PPM and on-time delivery have been consistently strong.",
        name: "Hanae Mori",
        company: "Kite Automotive",
        designation: "Supplier Development",
        sortOrder: 1,
      },
      {
        quote:
          "B7 studs with PTFE coating, 3.2 certificates and packing that survived a rough transhipment. That is the standard we now specify.",
        name: "Yusuf Al-Harthy",
        company: "Gulf Petro Systems",
        designation: "Materials Manager",
        sortOrder: 2,
      },
    ],
  });

  const author = await prisma.blogAuthor.create({
    data: {
      name: "Dr. Kavita Rao",
      title: "Chief Applications Engineer",
      bio: "Twenty years in fastener metallurgy, coatings and joint design.",
    },
  });
  const author2 = await prisma.blogAuthor.create({
    data: {
      name: "Arjun Desai",
      title: "Export Manager",
      bio: "Leads Helvix documentation and international logistics.",
    },
  });

  const blogCats = await Promise.all(
    [
      ["Fastener Guides", "fastener-guides"],
      ["Product Knowledge", "product-knowledge"],
      ["Technical Articles", "technical-articles"],
      ["Industry Applications", "industry-applications"],
      ["Company Updates", "company-updates"],
      ["Import & Export", "import-export"],
      ["Engineering Insights", "engineering-insights"],
    ].map(([name, slug]) => prisma.blogCategory.create({ data: { name, slug } })),
  );

  const bcat = Object.fromEntries(blogCats.map((c) => [c.slug, c]));

  await prisma.blog.createMany({
    data: [
      {
        title: "How to specify hex bolts for structural steel",
        slug: "specify-hex-bolts-structural-steel",
        excerpt:
          "A practical path from joint type to standard, grade, finish and assembly — without over-specifying cost.",
        content:
          "## Start with the joint\n\nStructural joints are either bearing or slip-critical. That single decision drives whether you need a standard hex bolt or a preloaded heavy-hex system such as ASTM F3125 or EN 14399.\n\n## Grade is not a marketing term\n\nProperty class 8.8 is not interchangeable with A325, and 10.9 is not a drop-in for A490. Match the standard family to the design code on the drawing.\n\n## Finish and hydrogen\n\nHot-dip galvanizing high-strength bolts requires controlled process practice. A490 is not galvanized. If corrosion protection is mandatory, discuss zinc flake or alternative joint protection with the engineer.\n\n## Assemblies beat loose pieces\n\nSpecify bolt, nut and washer as a matched set. It reduces site errors and makes rotational-capacity or k-class testing meaningful.\n\nHelvix applications engineers review drawings daily. Send the joint schedule with your enquiry.",
        image: "/images/blog/hex-bolts.jpg",
        categoryId: bcat["fastener-guides"].id,
        authorId: author.id,
        featured: true,
        seoTitle: "How to specify hex bolts for structural steel | Helvix",
        seoDesc:
          "A practical guide to choosing structural bolt standards, grades and finishes.",
        seoKeywords: "structural bolts, A325, hex bolts, specification",
      },
      {
        title: "Property class 8.8 vs 10.9 vs 12.9",
        slug: "property-class-8-8-10-9-12-9",
        excerpt:
          "What the numbers actually mean for tensile strength, ductility and hydrogen embrittlement risk.",
        content:
          "## The two numbers\n\nIn ISO 898-1 the first number times 100 is approximate tensile strength in MPa. The second, times ten, is the yield ratio. Class 10.9 therefore implies 1000 MPa tensile and 900 MPa yield.\n\n## Ductility trade-off\n\n12.9 offers more clamp for a given diameter but less plastic reserve. It is the default for socket products in tooling, not for galvanized outdoor structures.\n\n## Coating caution\n\nThe higher the hardness, the more carefully electroplating must be controlled. Prefer zinc flake or mechanical finishes when specifying 10.9 and 12.9 in corrosive environments.",
        image: "/images/blog/grades.jpg",
        categoryId: bcat["product-knowledge"].id,
        authorId: author.id,
        seoTitle: "8.8 vs 10.9 vs 12.9 fastener grades | Helvix",
        seoDesc: "Understand ISO property classes and when each grade is the right choice.",
      },
      {
        title: "Coatings that survive marine and chemical plants",
        slug: "fastener-coatings-marine-chemical",
        excerpt:
          "HDG, zinc flake, PTFE and stainless — a field guide for specifiers.",
        content:
          "Hot-dip galvanizing remains the workhorse for structural steel. Zinc flake systems (often Geomet or Delta variants) give high salt-spray hours without the hydrogen risk of some electroplates. Fluoropolymer topcoats on B7 studs are the offshore default because they combine corrosion resistance with predictable torque-tension.\n\nStainless is not a coating. It is a material choice with its own galling and chloride-pitting limits. Helvix can supply comparative salt-spray data with quotations.",
        image: "/images/blog/coatings.jpg",
        categoryId: bcat["technical-articles"].id,
        authorId: author.id,
      },
      {
        title: "Export documentation that clears the first time",
        slug: "export-documentation-fasteners",
        excerpt:
          "Commercial invoice, packing list, certificate of origin, 3.1 mill certs and fumigation — the set buyers actually need.",
        content:
          "Most delayed fastener shipments are paperwork, not production. We pack to ISPM-15, issue EN 10204 3.1 certificates against heat numbers, and align HS codes with the destination broker before the container is sealed.\n\nIf your project requires third-party inspection, nominate the agency at order stage so hold-points are planned rather than improvised.",
        image: "/images/blog/export.jpg",
        categoryId: bcat["import-export"].id,
        authorId: author2.id,
      },
      {
        title: "Anchoring plant skids to concrete",
        slug: "anchoring-plant-skids-concrete",
        excerpt:
          "Wedge versus chemical anchors, edge distances and what to send with the RFQ.",
        content:
          "Through-bolted wedge anchors are fast when slab thickness and edge distance allow. Chemical anchors win when vibration, cracked concrete or close edges are in play. Always send the base-plate drawing, concrete grade and seismic category with the enquiry — the diameter is rarely the only variable.",
        image: "/images/blog/anchors.jpg",
        categoryId: bcat["industry-applications"].id,
        authorId: author.id,
      },
      {
        title: "Helvix Sanand inspection lab expansion",
        slug: "sanand-inspection-lab-expansion",
        excerpt:
          "New optical measurement and coating-thickness capacity is now online.",
        content:
          "The Sanand quality lab has added optical thread measurement and XRF coating thickness, shortening first-article cycles for custom fasteners. Customers with open PPAP projects will see the new capability listed on updated control plans.",
        image: "/images/blog/iso.jpg",
        categoryId: bcat["company-updates"].id,
        authorId: author2.id,
      },
    ],
  });

  await prisma.pageContent.createMany({
    data: [
      {
        slug: "about",
        title: "Built around the joint, not just the part",
        subtitle: "Nearly three decades of industrial fastener manufacture and export.",
        body: "Helvix Industrial was founded in Ahmedabad to give infrastructure and OEM buyers a single accountable source for standard and special fasteners. Today the Sanand campus and a qualified partner network cover forging, CNC, heat treatment, coating, inspection and export packing.\n\nWe supply domestic projects and ship to more than forty countries. The commercial desk, applications engineering and documentation team sit in the same building as production planning — so a drawing question does not disappear into a reseller chain.",
        image: "/images/about/plant.jpg",
        seoTitle: "About Helvix Industrial | Fastener Manufacturer & Exporter",
        seoDesc:
          "Learn about Helvix Industrial, a precision fastener manufacturer and global exporter based in Sanand, India.",
      },
      {
        slug: "quality",
        title: "Quality that can be audited",
        subtitle: "Process control, certificates and open inspection.",
        body: "Every critical lot carries a heat number, dimensional record and, where specified, coating and mechanical test data. ISO 9001 frames the system; EN 10204 3.1 and 3.2 documents travel with the goods. Buyer-nominated inspection is welcome.",
        image: "/images/factory/inspection.jpg",
        seoTitle: "Quality & Certifications | Helvix Industrial",
        seoDesc:
          "ISO certifications, material certificates, inspection and testing capabilities at Helvix Industrial.",
      },
      {
        slug: "manufacturing",
        title: "Infrastructure that can take a drawing",
        subtitle: "From raw bar to packed container.",
        body: "Forging, CNC, thread rolling, heat treatment, coating and a warehouse sized for programme stock. Specials and standards move through the same quality gate.",
        image: "/images/factory/cnc-close.jpg",
        seoTitle: "Manufacturing & Infrastructure | Helvix Industrial",
        seoDesc:
          "Explore Helvix manufacturing infrastructure: CNC, forging, warehouse, inspection and dispatch.",
      },
      {
        slug: "global-reach",
        title: "Global reach. Local commitment.",
        subtitle: "Supplying industrial customers across international markets.",
        body: "Helvix ships fasteners with the paperwork, packing and inspection that international projects require. Regional desks cover the Americas, Europe, Middle East, Africa and Asia-Pacific.",
        image: "/images/hero/hero-factory.jpg",
        seoTitle: "Global Reach | Helvix Industrial Fasteners",
        seoDesc:
          "Helvix supplies industrial fasteners to customers across 40+ countries with full export support.",
      },
      {
        slug: "import-export",
        title: "Import discipline. Export certainty.",
        subtitle: "Two complementary supply motions, one quality system.",
        body: "We source globally when a specification or volume demands it, and we export from India with complete documentation and logistics control.",
        seoTitle: "Import & Export | Helvix Industrial",
        seoDesc:
          "Global sourcing and export logistics for industrial fasteners from Helvix Industrial.",
      },
    ],
  });

  await prisma.enquiry.createMany({
    data: [
      {
        type: "product",
        name: "James Whitaker",
        company: "Northline Fabrication",
        email: "james@northline.example",
        phone: "+1 312 555 0199",
        country: "United States",
        productName: "ASTM A325 Structural Bolt",
        quantity: "12,000 sets",
        spec: "A325 Type 1, 7/8-9 x 3-1/2, mechanically galvanized, with A563 and F436",
        message: "Need CIF Houston, inspection by buyer at origin.",
        status: "Quoted",
      },
      {
        type: "quote",
        name: "Fatima Noor",
        company: "Desert Arc EPC",
        email: "fatima@desertarc.example",
        phone: "+971 50 000 0000",
        country: "UAE",
        productName: "ASTM A193 B7 Stud Bolt",
        quantity: "Project BOM attached later",
        message: "Flange studs for a desalination package. PTFE coated.",
        status: "New",
      },
    ],
  });

  console.log("Helvix database seeded.");
}

main()
  .then(() => prisma.$disconnect())
  .catch(async (e) => {
    console.error(e);
    await prisma.$disconnect();
    process.exit(1);
  });
