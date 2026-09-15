import { TECH_STACK, SOURCES } from "@/lib/site";
import { Icon } from "./Icon";
import SectionHeader from "./SectionHeader";

export default function TechStack() {
  return (
    <section id="teknologi" className="section">
      <div className="shell">
        <SectionHeader
          eyebrow="Teknologi"
          eyebrowIcon="Cpu"
          title={
            <>
              Yang dipasang di <span className="gradient-text">server Anda</span>
            </>
          }
          lead="Semuanya berasal dari repository resmi masing-masing proyek — tanpa paket pihak ketiga, tanpa binari misterius."
        />

        <div className="mt-14 grid gap-px overflow-hidden rounded-2xl border border-white/[0.07] bg-white/[0.03] sm:grid-cols-2 lg:grid-cols-3">
          {TECH_STACK.map((tech, index) => (
            <div
              key={tech.name}
              className="group bg-ink-900/60 p-5 transition-colors hover:bg-ink-800/60"
              data-reveal
              style={{ ["--reveal-delay" as string]: `${(index % 3) * 60}ms` }}
            >
              <div className="flex items-center justify-between gap-3">
                <span className="icon-tile" style={{ ["--tile-accent" as string]: tech.accent }}>
                  <Icon name={tech.icon} className="h-5 w-5" style={{ color: tech.accent }} />
                </span>
                <span className="font-mono text-[11.5px] text-slate-500">{tech.version}</span>
              </div>
              <h3 className="mt-4 text-[0.9375rem] font-semibold text-white">{tech.name}</h3>
              <p className="mt-1.5 text-[13px] leading-relaxed text-slate-400">{tech.description}</p>
            </div>
          ))}
        </div>

        {/* Sumber rilis */}
        <div className="mt-10 grid gap-4 sm:grid-cols-3">
          {SOURCES.map((source, index) => (
            <a
              key={source.title}
              href={source.url}
              target="_blank"
              rel="noopener noreferrer"
              className="card card-hover group flex flex-col p-5"
              data-reveal
              style={{ ["--reveal-delay" as string]: `${index * 70}ms` }}
            >
              <div className="flex items-center justify-between">
                <Icon name="Github" className="h-4 w-4 text-slate-500" />
                <Icon
                  name="ArrowUpRight"
                  className="h-4 w-4 text-slate-600 transition-transform group-hover:-translate-y-0.5 group-hover:translate-x-0.5 group-hover:text-cyan-brand"
                />
              </div>
              <h3 className="mt-4 font-mono text-[13px] text-slate-100">{source.title}</h3>
              <p className="mt-1.5 flex-1 text-[13px] leading-relaxed text-slate-400">
                {source.description}
              </p>
              <span className="mt-4 text-[11.5px] uppercase tracking-[0.12em] text-slate-600">
                {source.meta}
              </span>
            </a>
          ))}
        </div>
      </div>
    </section>
  );
}
