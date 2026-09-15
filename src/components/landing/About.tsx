import { TEAM, TIMELINE, SITE } from "@/lib/site";
import { Icon } from "./Icon";
import SectionHeader from "./SectionHeader";

const PRINCIPLES = [
  {
    icon: "ShieldCheck",
    title: "Hanya sumber resmi",
    text: "Semua paket berasal dari repository distribusi dan rilis resmi Pterodactyl.",
  },
  {
    icon: "Scale",
    title: "Berlisensi bebas",
    text: `Kode terbuka dengan lisensi ${SITE.license} — boleh dibaca, diubah, dan dipakai ulang.`,
  },
  {
    icon: "RefreshCw",
    title: "Idempotent",
    text: "Aman dijalankan ulang: instalasi yang ada dideteksi dan tidak ditimpa tanpa konfirmasi.",
  },
  {
    icon: "Heart",
    title: "Untuk komunitas",
    text: "Dibuat oleh komunitas game server hosting Indonesia, dipakai gratis tanpa batasan.",
  },
];

export default function About() {
  return (
    <section id="tentang" className="section">
      <div className="shell">
        <SectionHeader
          eyebrow="Tentang"
          eyebrowIcon="Users"
          title={
            <>
              Dibangun untuk <span className="gradient-text">yang ingin cepat</span>
            </>
          }
          lead="ArkanProjects lahir dari kebiasaan membaca panduan instalasi sepanjang 40 langkah. Installer ini merangkumnya jadi satu perintah yang bisa diaudit."
        />

        <div className="mt-14 grid gap-6 lg:grid-cols-[1.15fr_1fr]">
          {/* Prinsip */}
          <div className="grid gap-4 sm:grid-cols-2" data-reveal>
            {PRINCIPLES.map((item) => (
              <article key={item.title} className="card card-hover group p-5">
                <span className="icon-tile">
                  <Icon name={item.icon} className="h-5 w-5 text-cyan-brand" />
                </span>
                <h3 className="mt-4 text-[0.9375rem] font-semibold text-white">{item.title}</h3>
                <p className="mt-1.5 text-[13px] leading-relaxed text-slate-400">{item.text}</p>
              </article>
            ))}
          </div>

          {/* Tim + roadmap */}
          <div className="flex flex-col gap-4">
            <div className="card p-6" data-reveal style={{ ["--reveal-delay" as string]: "80ms" }}>
              <h3 className="text-sm font-semibold uppercase tracking-[0.12em] text-slate-300">
                Tim pengembang
              </h3>
              <ul className="mt-5 space-y-3">
                {TEAM.map((member) => (
                  <li key={member.name} className="flex items-center gap-3">
                    <span
                      className="flex h-9 w-9 shrink-0 items-center justify-center rounded-full border text-[13px] font-semibold"
                      style={{
                        color: member.accent,
                        borderColor: `color-mix(in oklab, ${member.accent} 35%, transparent)`,
                        background: `color-mix(in oklab, ${member.accent} 12%, transparent)`,
                      }}
                    >
                      {member.name.charAt(0)}
                    </span>
                    <span className="min-w-0">
                      <span className="block truncate text-[13.5px] text-slate-200">
                        {member.name}
                      </span>
                      <span className="block font-mono text-[11px] text-slate-500">
                        {member.role}
                      </span>
                    </span>
                  </li>
                ))}
              </ul>

              <a
                href={SITE.github}
                target="_blank"
                rel="noopener noreferrer"
                className="mt-5 inline-flex items-center gap-2 text-[13px] text-cyan-brand transition-colors hover:text-emerald-brand"
              >
                <Icon name="Github" className="h-4 w-4" />
                {SITE.github.replace("https://", "")}
                <Icon name="ExternalLink" className="h-3 w-3" />
              </a>
            </div>

            <div className="card p-6" data-reveal style={{ ["--reveal-delay" as string]: "160ms" }}>
              <h3 className="text-sm font-semibold uppercase tracking-[0.12em] text-slate-300">
                Riwayat rilis
              </h3>
              <ol className="mt-5 space-y-5">
                {TIMELINE.map((item, index) => (
                  <li key={item.version} className="relative pl-6">
                    <span
                      className="absolute left-0 top-1.5 h-2 w-2 rounded-full bg-cyan-brand"
                      aria-hidden="true"
                    />
                    {index < TIMELINE.length - 1 ? (
                      <span
                        className="absolute left-[3.5px] top-4 h-[calc(100%+0.6rem)] w-px bg-white/10"
                        aria-hidden="true"
                      />
                    ) : null}
                    <div className="flex items-center gap-2">
                      <span className="font-mono text-[13px] font-semibold text-cyan-brand">
                        {item.version}
                      </span>
                      <span className="rounded-md bg-white/[0.04] px-1.5 py-0.5 text-[10.5px] text-slate-500">
                        {item.date}
                      </span>
                    </div>
                    <p className="mt-1 text-[13px] leading-relaxed text-slate-400">
                      {item.description}
                    </p>
                  </li>
                ))}
              </ol>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
