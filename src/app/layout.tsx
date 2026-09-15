import type { Metadata, Viewport } from "next";
import { SITE } from "@/lib/site";
import "./globals.css";

export const metadata: Metadata = {
  metadataBase: new URL(SITE.url),
  title: {
    default: `${SITE.name} — ${SITE.tagline}`,
    template: `%s · ${SITE.name}`,
  },
  description: SITE.description,
  keywords: [
    "ArkanProjects",
    "Pterodactyl",
    "installer Pterodactyl",
    "Pterodactyl Panel",
    "Wings",
    "game server",
    "panel game hosting",
    "Docker",
    "Ubuntu",
    "Debian",
    "Rocky Linux",
    "AlmaLinux",
    "DevOps",
  ],
  authors: [
    { name: "Muhammad Rafif Rianto C.Ps" },
    { name: "Faturrahman Al Rizky" },
    { name: "Akhbar Alfiansyah" },
  ],
  creator: SITE.name,
  applicationName: SITE.name,
  alternates: { canonical: "/" },
  icons: {
    icon: [{ url: "/icon.svg", type: "image/svg+xml" }],
    shortcut: "/icon.svg",
  },
  openGraph: {
    type: "website",
    locale: "id_ID",
    url: SITE.url,
    siteName: SITE.name,
    title: `${SITE.name} — ${SITE.tagline}`,
    description: SITE.description,
  },
  twitter: {
    card: "summary_large_image",
    title: `${SITE.name} — ${SITE.tagline}`,
    description: SITE.description,
  },
  robots: { index: true, follow: true },
};

export const viewport: Viewport = {
  themeColor: "#05060b",
  colorScheme: "dark",
  width: "device-width",
  initialScale: 1,
};

export default function RootLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="id">
      <body>
        <noscript>
          {/* Tanpa JavaScript, semua konten tetap terlihat */}
          <style>{`[data-reveal]{opacity:1 !important;transform:none !important}`}</style>
        </noscript>

        <a
          href="#konten"
          className="sr-only focus:not-sr-only focus:fixed focus:left-4 focus:top-4 focus:z-[100] focus:rounded-lg focus:bg-ink-800 focus:px-4 focus:py-2 focus:text-sm focus:text-white"
        >
          Lewati ke konten
        </a>

        {children}
      </body>
    </html>
  );
}
