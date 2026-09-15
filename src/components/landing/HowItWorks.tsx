import { STEPS } from "@/lib/site";
import { Icon } from "./Icon";
import SectionHeader from "./SectionHeader";

export default function HowItWorks() {
  return (
    <section id="alur" className="section">
      <div className="shell">
        <SectionHeader
          eyebrow="Alur instalasi"
          eyebrowIcon="Layers"
          title={
            <>
              Enam tahap, <span className="gradient-text">tanpa langkah tersembunyi</span>
            </>
          }
          lead="Setiap tahap menampilkan progres dan hasilnya. Bila ada yang gagal, script berhenti dengan pesan yang menjelaskan penyebabnya."
          accent="var(--color-emerald-brand)"
        />

        <ol className="relative mt-14 space-y-4">
          {/* Garis penghubung */}
          <span
            aria-hidden="true"
            className="absolute left-[1.4rem] top-4 bottom-4 hidden w-px bg-gradient-to-b from-cyan-brand/40 via-violet-brand/30 to-transparent sm:block"
          />

          {STEPS.map((step, index) => (
            <li
              key={step.title}
              className="group relative sm:pl-16"
              data-reveal
              style={{ ["--reveal-delay" as string]: `${index * 60}ms` }}
            >
              {/* Penanda nomor */}
              <span
                className="absolute left-0 top-5 hidden h-12 w-12 items-center justify-center rounded-2xl border border-white/[0.08] bg-ink-900 font-mono text-sm text-slate-300 transition-colors group-hover:border-white/20 sm:flex"
                aria-hidden="true"
              >
                {String(index + 1).padStart(2, "0")}
              </span>

              <div className="card card-hover card-glow p-5 sm:p-6">
                <div className="flex flex-wrap items-start justify-between gap-3">
                  <div className="flex items-start gap-3.5">
                    <span
                      className="icon-tile"
                      style={{ ["--tile-accent" as string]: step.accent }}
                    >
                      <Icon name={step.icon} className="h-5 w-5" style={{ color: step.accent }} />
                    </span>
                    <div>
                      <h3 className="text-[1.0625rem] font-semibold text-white">{step.title}</h3>
                      <p className="mt-1.5 max-w-2xl text-sm leading-relaxed text-slate-400">
                        {step.description}
                      </p>
                    </div>
                  </div>

                  <span className="chip shrink-0 font-mono">
                    <Icon name="Clock" className="h-3 w-3" />
                    {step.duration}
                  </span>
                </div>
              </div>
            </li>
          ))}
        </ol>

        <p className="mt-8 text-center text-[13px] text-slate-500" data-reveal>
          Total estimasi: <span className="text-slate-300">±6 menit</span> pada VPS 2 vCPU / 4 GB RAM
          dengan koneksi stabil.
        </p>
      </div>
    </section>
  );
}
