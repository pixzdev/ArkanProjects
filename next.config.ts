import type { NextConfig } from "next";

/**
 * Konfigurasi produksi minimal — tanpa plugin tambahan.
 * Halaman di-prerender sebagai HTML statis sehingga tidak ada kerja server
 * yang diperlukan saat pengunjung membuka situs.
 */
const nextConfig: NextConfig = {
  output: "standalone",
  reactStrictMode: true,
  poweredByHeader: false,
  compress: true,
  productionBrowserSourceMaps: false,

  experimental: {
    // Kurangi bobot bundle dengan mengimpor hanya ikon yang dipakai.
    optimizePackageImports: ["lucide-react"],
  },

  async headers() {
    return [
      {
        // Script installer harus dilayani sebagai teks agar bisa di-pipe ke bash
        source: "/installer/:path*",
        headers: [
          { key: "Content-Type", value: "text/plain; charset=utf-8" },
          { key: "Cache-Control", value: "public, max-age=3600" },
        ],
      },
      {
        source: "/:path*",
        headers: [
          { key: "X-Content-Type-Options", value: "nosniff" },
          { key: "Referrer-Policy", value: "strict-origin-when-cross-origin" },
          { key: "Permissions-Policy", value: "camera=(), microphone=(), geolocation=()" },
        ],
      },
    ];
  },
};

export default nextConfig;
