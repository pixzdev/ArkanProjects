import { Github, Sparkles, ArrowRight, CheckCircle2 } from "lucide-react";
import { HERO_STATS, INSTALL_COMMAND, SITE } from "@/lib/site";
import CopyButton from "./CopyButton";
import TerminalDemo from "./TerminalDemo";

const HIGHLIGHTS = [
  `Panel ${SITE.panelVersion} · Wings ${SITE.wingsVersion}`,
  `PHP ${SITE.phpVersion} · MariaDB ${SITE.mariadbVersion}`,
  "Mode unattended + CLI arkan",
];

export default function Hero() {
  return (
    <section id="atas" className="relative overflow-hidden pt-28 pb-16 sm:pt-32 lg:pt-36 lg:pb-24">
      <div className="shell relative">
        <div className="grid items-center gap-12 lg:grid-cols-[1.05fr_1fr] lg:gap-14">
          {/* Kolom kiri — narasi */}
          <div className="flex flex-col items-start">
            <span className="eyebrow" data-reveal>
              <span className="dot-live" />
              v{SITE.installerVersion} — mode unattended &amp; CLI arkan
            </span>

            <h1
              className="mt-5 text-balance text-[2.1rem] font-semibold leading-[1.08] tracking-tight text-white sm:text-5xl lg:text-[3.4rem]"
              data-reveal
              style={{ ["--reveal-delay" as string]: "60ms" }}
            >
              Pasang <span className="gradient-text">Pterodactyl</span> lengkap
              <br className="hidden sm:block" /> dalam satu perintah.
            </h1>

            <p
              className="lead mt-5 max-w-xl text-pretty"
              data-reveal
              style={{ ["--reveal-delay" as string]: "120ms" }}
            >
              {SITE.description} Tidak ada langkah manual, tidak ada konfigurasi
              yang terlupa — installer memeriksa sendiri OS, DNS, dan
              dependensinya.
            </p>

            {/* Perintah utama */}
            <div
              className="mt-7 w-full max-w-xl rounded-2xl border border-white/[0.08] bg-white/[0.03] p-3"
              data-reveal
              style={{ ["--reveal-delay" as string]: "180ms" }}
            >
              <div className="flex items-center gap-3">
                <code className="min-w-0 flex-1 overflow-x-auto whitespace-nowrap font-mono text-[12.5px] text-slate-200 sm:text-[13.5px]">
                  <span className="text-slate-500">$ </span>
                  {INSTALL_COMMAND}
                </code>
                <CopyButton value={INSTALL_COMMAND} />
              </div>
            </div>

            {/* CTA */}
            <div
              className="mt-6 flex flex-wrap items-center gap-3"
              data-reveal
              style={{ ["--reveal-delay" as string]: "240ms" }}
            >
              <a href="#instalasi" className="btn btn-primary">
                <Sparkles className="h-4 w-4" />
                Mulai instalasi
              </a>
              <a
                href={SITE.github}
                target="_blank"
                rel="noopener noreferrer"
                className="btn btn-ghost"
              >
                <Github className="h-4 w-4" />
                Lihat sumber
              </a>
            </div>

            {/* Sorotan singkat */}
            <ul
              className="mt-7 flex flex-wrap gap-x-5 gap-y-2 text-[13px] text-slate-400"
              data-reveal
              style={{ ["--reveal-delay" as string]: "300ms" }}
            >
              {HIGHLIGHTS.map((item) => (
                <li key={item} className="inline-flex items-center gap-2">
                  <CheckCircle2 className="h-3.5 w-3.5 text-emerald-brand" />
                  {item}
                </li>
              ))}
            </ul>
          </div>

          {/* Kolom kanan — terminal */}
          <div className="relative">
            <div className="absolute -inset-6 -z-10 rounded-[2rem] bg-[radial-gradient(circle_at_30%_20%,rgba(34,211,238,0.18),transparent_60%)] blur-2xl" />
            <TerminalDemo />
          </div>
        </div>

        {/* Statistik */}
        <div
          className="mt-14 grid grid-cols-2 gap-px overflow-hidden rounded-2xl border border-white/[0.07] bg-white/[0.02] sm:grid-cols-4 lg:mt-20"
          data-reveal
        >
          {HERO_STATS.map((stat) => (
            <div key={stat.label} className="px-5 py-5">
              <div className="font-mono text-2xl font-semibold text-white sm:text-3xl">
                {stat.value}
              </div>
              <div className="mt-1 text-xs text-slate-400 sm:text-[13px]">{stat.label}</div>
            </div>
          ))}
        </div>

        <div className="mt-6 flex justify-center" data-reveal>
          <a
            href="#fitur"
            className="inline-flex items-center gap-2 text-[13px] text-slate-500 transition-colors hover:text-cyan-brand"
          >
            Jelajahi fitur
            <ArrowRight className="h-3.5 w-3.5" />
          </a>
        </div>
      </div>
    </section>
  );
}
