"use client";

import { useState } from "react";
import { AlertCircle, ShieldCheck, Server, HardDrive, Globe } from "lucide-react";
import { INSTALL_MODES, REQUIREMENTS } from "@/lib/site";
import CopyButton from "./CopyButton";
import SectionHeader from "./SectionHeader";

const REQ_ICONS = [Server, HardDrive, HardDrive, ShieldCheck];

export default function InstallGuide() {
  const [activeId, setActiveId] = useState(INSTALL_MODES[0].id);
  const active = INSTALL_MODES.find((mode) => mode.id === activeId) ?? INSTALL_MODES[0];

  return (
    <section id="instalasi" className="section">
      <div className="shell">
        <SectionHeader
          eyebrow="Instalasi"
          title={
            <>
              Jalankan di server, <span className="gradient-text">sisanya otomatis</span>
            </>
          }
          lead="Pilih mode yang sesuai. Semua mode memakai script yang sama — hanya berbeda pada seberapa banyak yang dikirim lewat flag."
        />

        <div className="mt-14 grid gap-6 lg:grid-cols-[1.35fr_1fr]">
          {/* Panel perintah */}
          <div className="card overflow-hidden" data-reveal>
            <div role="tablist" aria-label="Mode instalasi" className="flex flex-wrap gap-1 border-b border-white/[0.06] p-2">
              {INSTALL_MODES.map((mode) => {
                const selected = mode.id === activeId;
                return (
                  <button
                    key={mode.id}
                    role="tab"
                    type="button"
                    aria-selected={selected}
                    onClick={() => setActiveId(mode.id)}
                    className={`rounded-xl px-3.5 py-2 text-[13px] font-medium transition-colors ${
                      selected
                        ? "bg-white/[0.07] text-white"
                        : "text-slate-400 hover:bg-white/[0.04] hover:text-slate-200"
                    }`}
                  >
                    {mode.label}
                  </button>
                );
              })}
            </div>

            <div className="p-4 sm:p-5">
              <div className="rounded-xl border border-white/[0.07] bg-ink-950/70 p-4">
                <div className="flex items-start gap-3">
                  <pre className="min-w-0 flex-1 overflow-x-auto whitespace-pre-wrap break-all font-mono text-[12.5px] leading-relaxed text-slate-200 sm:text-[13px]">
                    {active.command}
                  </pre>
                  <CopyButton value={active.command} label="Salin" />
                </div>
              </div>

              <p className="mt-3 text-[13px] leading-relaxed text-slate-400">{active.note}</p>
            </div>

            {/* Flag ringkas */}
            <div className="border-t border-white/[0.06] p-4 sm:p-5">
              <p className="text-xs uppercase tracking-[0.14em] text-slate-500">Flag utama</p>
              <div className="mt-3 flex flex-wrap gap-2">
                {["--panel", "--wings", "--both", "--fqdn", "--email", "--ssl", "--firewall", "--dbhost", "--yes", "--dry-run"].map(
                  (flag) => (
                    <code
                      key={flag}
                      className="rounded-lg border border-white/[0.07] bg-white/[0.03] px-2 py-1 font-mono text-[11.5px] text-cyan-brand"
                    >
                      {flag}
                    </code>
                  ),
                )}
              </div>
            </div>
          </div>

          {/* Persyaratan */}
          <div className="flex flex-col gap-4">
            <div className="card p-6" data-reveal style={{ ["--reveal-delay" as string]: "80ms" }}>
              <div className="flex items-center gap-2 text-slate-200">
                <AlertCircle className="h-4 w-4 text-pink-brand" />
                <h3 className="text-sm font-semibold uppercase tracking-[0.12em]">Sebelum mulai</h3>
              </div>

              <ul className="mt-5 space-y-3">
                {[
                  { icon: ShieldCheck, text: "Akses root atau sudo di server" },
                  { icon: Server, text: "VPS berbasis KVM (OpenVZ tidak mendukung Docker)" },
                  { icon: Globe, text: "Domain mengarah ke IP server bila ingin SSL otomatis" },
                  { icon: HardDrive, text: "curl terpasang — installer memasangnya bila belum ada" },
                ].map((item) => (
                  <li key={item.text} className="flex items-start gap-3 text-[13px] text-slate-400">
                    <item.icon className="mt-0.5 h-4 w-4 shrink-0 text-cyan-brand/70" />
                    <span>{item.text}</span>
                  </li>
                ))}
              </ul>
            </div>

            <div className="grid grid-cols-2 gap-px overflow-hidden rounded-2xl border border-white/[0.07] bg-white/[0.02]" data-reveal style={{ ["--reveal-delay" as string]: "160ms" }}>
              {REQUIREMENTS.map((req, index) => {
                const IconCmp = REQ_ICONS[index] ?? Server;
                return (
                  <div key={req.label} className="p-5">
                    <IconCmp className="h-4 w-4" style={{ color: req.accent }} />
                    <div className="mt-3 text-[11px] uppercase tracking-[0.14em] text-slate-500">
                      {req.label}
                    </div>
                    <div className="mt-1 text-lg font-semibold text-white">{req.value}</div>
                    <div className="mt-1 text-[11.5px] leading-snug text-slate-500">{req.hint}</div>
                  </div>
                );
              })}
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
