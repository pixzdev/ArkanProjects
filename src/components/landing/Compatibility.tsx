import { OS_LIST, REQUIREMENTS, COMPARE_ROWS } from "@/lib/site";
import { Icon } from "./Icon";
import SectionHeader from "./SectionHeader";

export default function Compatibility() {
  return (
    <section id="kompatibilitas" className="section">
      <div className="shell">
        <SectionHeader
          eyebrow="Kompatibilitas"
          eyebrowIcon="Server"
          title={
            <>
              Sembilan sistem resmi, <span className="gradient-text">satu perintah yang sama</span>
            </>
          }
          lead="Installer membaca /etc/os-release dan menyesuaikan repository paket, nama service, serta konfigurasi web server secara otomatis."
          accent="var(--color-emerald-brand)"
        />

        {/* Daftar OS */}
        <div className="mt-14 grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {OS_LIST.map((os, index) => (
            <article
              key={`${os.name}-${os.version}`}
              className="card card-hover group p-5"
              data-reveal
              style={{ ["--reveal-delay" as string]: `${(index % 3) * 60}ms` }}
            >
              <div className="flex items-start justify-between gap-3">
                <div>
                  <h3 className="text-[0.9375rem] font-semibold text-white">{os.name}</h3>
                  <p className="mt-0.5 font-mono text-[12px] text-slate-400">{os.version}</p>
                </div>
                <span
                  className="rounded-full border px-2 py-0.5 font-mono text-[10px] uppercase tracking-wider"
                  style={{
                    color: os.accent,
                    borderColor: `color-mix(in oklab, ${os.accent} 35%, transparent)`,
                    background: `color-mix(in oklab, ${os.accent} 10%, transparent)`,
                  }}
                >
                  {os.status}
                </span>
              </div>

              <p className="mt-3 text-[12.5px] italic text-slate-500">{os.codename}</p>

              <div className="mt-4 flex flex-wrap gap-1.5">
                {os.archs.map((arch) => (
                  <span
                    key={arch}
                    className="rounded-md border border-white/[0.08] bg-white/[0.03] px-2 py-0.5 font-mono text-[10.5px] text-slate-400"
                  >
                    {arch}
                  </span>
                ))}
              </div>
            </article>
          ))}
        </div>

        {/* Spesifikasi minimum */}
        <div
          className="mt-8 grid grid-cols-2 gap-px overflow-hidden rounded-2xl border border-white/[0.07] bg-white/[0.03] lg:grid-cols-4"
          data-reveal
        >
          {REQUIREMENTS.map((req) => (
            <div key={req.label} className="bg-ink-900/60 p-5">
              <div className="text-[11px] uppercase tracking-[0.14em] text-slate-500">
                {req.label}
              </div>
              <div className="mt-1.5 text-xl font-semibold text-white">{req.value}</div>
              <div className="mt-1 text-[11.5px] leading-snug text-slate-500">{req.hint}</div>
            </div>
          ))}
        </div>

        {/* Perbandingan manual vs installer */}
        <div className="mt-16" data-reveal>
          <h3 className="text-center text-lg font-semibold text-white">
            Manual vs <span className="gradient-text">ArkanProjects</span>
          </h3>
          <div className="mt-6 overflow-hidden rounded-2xl border border-white/[0.07]">
            <div className="hidden grid-cols-[1.1fr_1fr_1fr] gap-px bg-white/[0.05] sm:grid">
              <div className="bg-ink-850 px-5 py-3 text-[11px] uppercase tracking-[0.14em] text-slate-500">
                Aspek
              </div>
              <div className="bg-ink-850 px-5 py-3 text-[11px] uppercase tracking-[0.14em] text-slate-500">
                Instal manual
              </div>
              <div className="bg-ink-850 px-5 py-3 text-[11px] uppercase tracking-[0.14em] text-cyan-brand">
                Installer
              </div>
            </div>

            <div className="divide-y divide-white/[0.05]">
              {COMPARE_ROWS.map((row) => (
                <div
                  key={row.label}
                  className="grid gap-px bg-white/[0.02] sm:grid-cols-[1.1fr_1fr_1fr]"
                >
                  <div className="bg-ink-900/70 px-5 py-3.5 text-[13px] font-medium text-slate-200">
                    {row.label}
                  </div>
                  <div className="flex items-start gap-2 bg-ink-900/70 px-5 py-3.5 text-[13px] text-slate-500">
                    <Icon name="X" className="mt-0.5 h-3.5 w-3.5 shrink-0 text-pink-brand/60" />
                    {row.manual}
                  </div>
                  <div className="flex items-start gap-2 bg-ink-900/70 px-5 py-3.5 text-[13px] text-slate-300">
                    <Icon name="Check" className="mt-0.5 h-3.5 w-3.5 shrink-0 text-emerald-brand" />
                    {row.arkan}
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
