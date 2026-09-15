import { CLI_COMMANDS, SITE } from "@/lib/site";
import { Icon } from "./Icon";
import SectionHeader from "./SectionHeader";
import CopyButton from "./CopyButton";

export default function CliSection() {
  return (
    <section id="cli" className="section">
      <div className="shell">
        <SectionHeader
          eyebrow="Setelah instalasi"
          eyebrowIcon="Terminal"
          title={
            <>
              Dikelola lewat <span className="gradient-text">perintah arkan</span>
            </>
          }
          lead="Installer menanam CLI kecil di /usr/local/bin/arkan supaya Anda tidak perlu menghafal path, nama service, atau urutan perintah artisan."
          accent="var(--color-violet-brand)"
        />

        <div className="mt-14 grid gap-6 lg:grid-cols-[1fr_1.1fr]">
          {/* Contoh output */}
          <div className="term" data-reveal>
            <div className="term-bar">
              <span className="term-dot bg-[#ff5f57]/80" />
              <span className="term-dot bg-[#febc2e]/80" />
              <span className="term-dot bg-[#28c840]/80" />
              <span className="ml-2 font-mono text-[11px] text-slate-500">arkan doctor</span>
            </div>
            <div className="p-4 font-mono text-[12.5px] leading-[1.85]">
              <div className="text-cyan-brand">$ arkan doctor</div>
              <div className="text-slate-600">&nbsp;</div>
              <div className="text-slate-400">  OS ............... Ubuntu 24.04 LTS (amd64)</div>
              <div className="text-slate-400">  Panel ............ v{SITE.panelVersion.replace(".x", ".1")} — /var/www/pterodactyl</div>
              <div className="text-emerald-brand">  php8.3-fpm ....... aktif · socket ok</div>
              <div className="text-emerald-brand">  nginx ............ aktif · config valid</div>
              <div className="text-emerald-brand">  mariadb .......... aktif · koneksi panel ok</div>
              <div className="text-emerald-brand">  redis ............ aktif · PONG</div>
              <div className="text-emerald-brand">  pteroq ........... aktif · 0 job gagal</div>
              <div className="text-slate-400">  wings ............ belum dikonfigurasi (config.yml kosong)</div>
              <div className="text-emerald-brand">  TLS .............. valid 89 hari · auto-renew aktif</div>
              <div className="text-slate-400">  DNS .............. panel.domain.com → 203.0.113.10</div>
              <div className="text-slate-600">&nbsp;</div>
              <div className="text-slate-100">  Hasil: 8 ok · 1 perlu tindakan</div>
            </div>
          </div>

          {/* Daftar perintah */}
          <div className="card divide-y divide-white/[0.05] overflow-hidden" data-reveal style={{ ["--reveal-delay" as string]: "80ms" }}>
            {CLI_COMMANDS.map((item) => (
              <div
                key={item.command}
                className="group flex flex-col gap-1.5 p-4 transition-colors hover:bg-white/[0.03] sm:flex-row sm:items-center sm:justify-between sm:gap-4"
              >
                <div className="flex items-center gap-3">
                  <Icon
                    name="ArrowRight"
                    className="h-3.5 w-3.5 shrink-0 text-violet-brand/70 transition-transform group-hover:translate-x-0.5"
                  />
                  <code className="font-mono text-[13px] text-slate-100">{item.command}</code>
                </div>
                <p className="pl-6 text-[12.5px] leading-snug text-slate-500 sm:max-w-[58%] sm:pl-0 sm:text-right">
                  {item.description}
                </p>
              </div>
            ))}

            <div className="flex items-center justify-between gap-3 bg-white/[0.02] p-4">
              <span className="text-[12.5px] text-slate-500">
                CLI tersedia otomatis setelah instalasi selesai.
              </span>
              <CopyButton value="arkan status" label="Salin contoh" />
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
