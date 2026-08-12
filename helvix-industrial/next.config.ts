import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  allowedDevOrigins: [
    "3000-icy2uc1mapu7r0eys5png.e2b.app",
    "*.e2b.app",
    "*.e2b.dev",
    "*.arena.ai",
    "localhost",
    "127.0.0.1",
  ],
  images: {
    formats: ["image/avif", "image/webp"],
    deviceSizes: [640, 768, 1024, 1280, 1600, 1920],
    imageSizes: [64, 96, 128, 256, 384],
  },
  experimental: {
    serverActions: {
      bodySizeLimit: "12mb",
      allowedOrigins: [
        "*.e2b.app",
        "*.e2b.dev",
        "localhost:3000",
        "127.0.0.1:3000",
      ],
    },
  },
};

export default nextConfig;
