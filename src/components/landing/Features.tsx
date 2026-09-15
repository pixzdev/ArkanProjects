import { FEATURES } from "@/lib/site";
import { Icon } from "./Icon";
import SectionHeader from "./SectionHeader";

export default function Features() {
  return (
    <section id="fitur" className="section">
      <div className="shell">
        <SectionHeader
          eyebrow="Fitur"
          eyebrowIcon="Sparkles"
          title={
            <>
              Semua yang dibutuhkan, <span className="gradient-text">sudah otomatis</span>
            </>
          }
          lead="Sembilan hal yang biasanya harus Anda kerjakan sendiri setelah mengikuti panduan instalasi — sekarang ditangani installer, termasuk backup, update, dan diagnosa."
        />

        <div className="mt-14 grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {FEATURES.map((feature, index) => (
            <article
              key={feature.title}
              className="card card-hover card-glow group p-6"
              data-reveal
              style={{ ["--reveal-delay" as string]: `${(index % 3) * 70}ms` }}
            >
              <span
                className="icon-tile"
                style={{ ["--tile-accent" as string]: feature.accent }}
              >
                <Icon name={feature.icon} className="h-5 w-5" style={{ color: feature.accent }} />
              </span>

              <h3 className="mt-5 text-[1.0625rem] font-semibold text-white">{feature.title}</h3>
              <p className="mt-2 text-sm leading-relaxed text-slate-400">{feature.description}</p>

              <span
                className="mt-5 block h-px w-10 transition-all duration-500 group-hover:w-full"
                style={{ background: `linear-gradient(90deg, ${feature.accent}, transparent)` }}
              />
            </article>
          ))}
        </div>
      </div>
    </section>
  );
}
