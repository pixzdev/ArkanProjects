import { Github, BookOpen, MessageSquare, Terminal, Heart } from "lucide-react";
import { INSTALL_COMMAND, NAV_LINKS, SITE } from "@/lib/site";
import { LogoLock } from "./Logo";
import CopyButton from "./CopyButton";

const LINKS = [
  { label: "Repositori", href: SITE.github, icon: Github },
  { label: "Dokumentasi Pterodactyl", href: "https://pterodactyl.io", icon: BookOpen },
  { label: "Komunitas Discord", href: "https://pterodactyl.io/discord.html", icon: MessageSquare },
  { label: "Script installer", href: SITE.installer, icon: Terminal },
];

export default function Footer() {
  return (
    <footer className="relative overflow-hidden border-t border-white/[0.06] pb-10 pt-16">
      <div className="absolute inset-x-0 top-0 h-px bg-gradient-to-r from-transparent via-cyan-brand/40 to-transparent" />
      <div className="shell">
        <div className="grid gap-10 lg:grid-cols-[1.4fr_1fr_1fr]">
          <div>
            <LogoLock />
            <p className="mt-4 max-w-sm text-[13.5px] leading-relaxed text-slate-400">
              Installer Pterodactyl Panel &amp; Wings untuk Ubuntu, Debian, Rocky Linux, dan
              AlmaLinux. Terbuka, dapat diaudit, dan gratis dipakai.
            </p>

            <div className="mt-5 flex max-w-sm items-center gap-2 rounded-xl border border-white/[0.07] bg-white/[0.03] px-3 py-2">
              <code className="min-w-0 flex-1 truncate font-mono text-[12px] text-slate-300">
                {INSTALL_COMMAND}
              </code>
              <CopyButton value={INSTALL_COMMAND} />
            </div>
          </div>

          <nav aria-label="Tautan bagian">
            <h3 className="text-[11px] uppercase tracking-[0.14em] text-slate-500">Bagian</h3>
            <ul className="mt-4 space-y-2.5">
              {NAV_LINKS.map((link) => (
                <li key={link.href}>
                  <a
                    href={link.href}
                    className="text-[13.5px] text-slate-400 transition-colors hover:text-cyan-brand"
                  >
                    {link.label}
                  </a>
                </li>
              ))}
            </ul>
          </nav>

          <div>
            <h3 className="text-[11px] uppercase tracking-[0.14em] text-slate-500">Tautan</h3>
            <ul className="mt-4 space-y-2.5">
              {LINKS.map((link) => (
                <li key={link.label}>
                  <a
                    href={link.href}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="inline-flex items-center gap-2 text-[13.5px] text-slate-400 transition-colors hover:text-cyan-brand"
                  >
                    <link.icon className="h-3.5 w-3.5" />
                    {link.label}
                  </a>
                </li>
              ))}
            </ul>
          </div>
        </div>

        <div className="mt-12 flex flex-col gap-4 border-t border-white/[0.05] pt-6 sm:flex-row sm:items-center sm:justify-between">
          <p className="text-[12px] text-slate-500">
            © {new Date().getFullYear()} {SITE.name} · Lisensi {SITE.license} · Installer v
            {SITE.installerVersion}
          </p>
          <p className="flex flex-wrap items-center gap-2 text-[12px] text-slate-600">
            <span className="inline-flex items-center gap-1">
              Dibuat dengan <Heart className="h-3 w-3 text-pink-brand/60" /> oleh komunitas
            </span>
            <span aria-hidden="true">·</span>
            <span>Tidak berafiliasi resmi dengan Pterodactyl</span>
          </p>
        </div>
      </div>
    </footer>
  );
}
