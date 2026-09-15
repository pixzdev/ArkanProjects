import { FAQ_ITEMS, SITE } from "@/lib/site";
import { Icon } from "./Icon";
import SectionHeader from "./SectionHeader";

export default function Faq() {
  return (
    <section id="faq" className="section">
      <div className="shell">
        <SectionHeader
          eyebrow="FAQ"
          eyebrowIcon="Shield"
          title={
            <>
              Pertanyaan yang <span className="gradient-text">sering muncul</span>
            </>
          }
          lead="Delapan hal yang paling sering ditanyakan sebelum memasang Pterodactyl di server sendiri."
          accent="var(--color-pink-brand)"
        />

        <div className="mx-auto mt-14 max-w-3xl">
          {FAQ_ITEMS.map((item, index) => (
            <details
              key={item.question}
              className="group card mb-3 overflow-hidden transition-colors open:border-cyan-brand/25"
              data-reveal
              style={{ ["--reveal-delay" as string]: `${Math.min(index, 5) * 50}ms` }}
            >
              <summary className="flex cursor-pointer list-none items-center justify-between gap-4 p-5 text-left [&::-webkit-details-marker]:hidden">
                <span className="text-[0.9375rem] font-medium text-slate-100 transition-colors group-hover:text-cyan-brand">
                  {item.question}
                </span>
                <Icon
                  name="ChevronDown"
                  className="h-4 w-4 shrink-0 text-slate-500 transition-transform duration-300 group-open:rotate-180 group-open:text-cyan-brand"
                />
              </summary>
              <div className="border-t border-white/[0.05] px-5 py-4">
                <p className="text-[13.5px] leading-relaxed text-slate-400">{item.answer}</p>
              </div>
            </details>
          ))}

          <p className="mt-8 text-center text-[13px] text-slate-500" data-reveal>
            Belum terjawab? Buka diskusi di{" "}
            <a
              href={`${SITE.github}/issues`}
              target="_blank"
              rel="noopener noreferrer"
              className="text-cyan-brand underline decoration-cyan-brand/30 underline-offset-4 transition-colors hover:decoration-cyan-brand"
            >
              GitHub Issues
            </a>
            .
          </p>
        </div>
      </div>
    </section>
  );
}
