"use client";

import { useEffect, useRef, useState } from "react";
import { INSTALL_COMMAND } from "@/lib/site";
import CopyButton from "./CopyButton";
import { SITE } from "@/lib/site";

type Tone = "prompt" | "brand" | "muted" | "info" | "ok" | "warn" | "done";

interface Line {
  text: string;
  tone: Tone;
  pause: number;
}

const SCRIPT: Line[] = [
  { text: `$ bash <(curl -s ${SITE.installer})`, tone: "prompt", pause: 620 },
  { text: "", tone: "muted", pause: 60 },
  { text: "  ArkanProjects Installer  v2.0.0", tone: "brand", pause: 260 },
  { text: "  ─────────────────────────────────────────────", tone: "muted", pause: 90 },
  { text: "  [i] Sistem: Ubuntu 24.04 LTS · amd64 · KVM · 4 vCPU · 4 GB RAM", tone: "info", pause: 320 },
  { text: "  [i] Panel terbaru v1.15.1  ·  Wings terbaru v1.13.3", tone: "info", pause: 240 },
  { text: "", tone: "muted", pause: 120 },
  { text: "  [?] Mode instalasi ............ Panel + Wings", tone: "brand", pause: 220 },
  { text: "  [?] FQDN ...................... panel.domain.com", tone: "brand", pause: 220 },
  { text: "  [?] Let's Encrypt ............. ya", tone: "brand", pause: 220 },
  { text: "  [?] Firewall (UFW) ............ ya", tone: "brand", pause: 260 },
  { text: "", tone: "muted", pause: 120 },
  { text: "  [1/6] Dependensi: php8.3 · mariadb 11.4 · nginx · redis", tone: "ok", pause: 420 },
  { text: "  [2/6] Panel v1.15.1 diunduh · composer install", tone: "ok", pause: 460 },
  { text: "  [3/6] Database panel + user dibuat (password acak 64 char)", tone: "ok", pause: 420 },
  { text: "  [4/6] Migrasi selesai · akun admin dibuat", tone: "ok", pause: 460 },
  { text: "  [5/6] Nginx + TLS 1.3 · Certbot auto-renew aktif", tone: "ok", pause: 420 },
  { text: "  [6/6] Wings v1.13.3 · Docker CE · systemd aktif", tone: "ok", pause: 520 },
  { text: "", tone: "muted", pause: 120 },
  { text: "  ✓ Selesai dalam 5 menit 42 detik", tone: "done", pause: 420 },
  { text: "  → Panel aktif di https://panel.domain.com", tone: "done", pause: 460 },
  { text: "  → Log: /var/log/arkanprojects-installer.log", tone: "muted", pause: 360 },
  { text: "", tone: "muted", pause: 180 },
  { text: "$ arkan status", tone: "prompt", pause: 0 },
];

const TONE_CLASS: Record<Tone, string> = {
  prompt: "text-cyan-brand",
  brand: "text-violet-brand",
  muted: "text-slate-600",
  info: "text-slate-400",
  ok: "text-emerald-brand",
  warn: "text-amber-400",
  done: "text-slate-100",
};

export default function TerminalDemo({ height = "h-[21rem]" }: { height?: string }) {
  const [count, setCount] = useState(0);
  const scrollRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const reduced =
      typeof window.matchMedia === "function" &&
      window.matchMedia("(prefers-reduced-motion: reduce)").matches;

    let index = 0;
    let timer: ReturnType<typeof setTimeout>;

    const step = () => {
      setCount(index + 1);
      const pause = reduced ? 0 : SCRIPT[index]?.pause ?? 200;
      index += 1;
      if (index < SCRIPT.length) timer = setTimeout(step, pause);
    };

    // Saat pengguna meminta gerak minimal, seluruh baris langsung ditampilkan.
    timer = setTimeout(step, reduced ? 0 : 500);
    return () => clearTimeout(timer);
  }, []);

  useEffect(() => {
    const node = scrollRef.current;
    if (node) node.scrollTop = node.scrollHeight;
  }, [count]);

  const finished = count >= SCRIPT.length;

  return (
    <div className="term" data-reveal="scale">
      <div className="term-bar">
        <span className="term-dot bg-[#ff5f57]/80" />
        <span className="term-dot bg-[#febc2e]/80" />
        <span className="term-dot bg-[#28c840]/80" />
        <span className="ml-2 font-mono text-[11px] text-slate-500">arkan@vps — bash</span>
        <div className="ml-auto">
          <CopyButton value={INSTALL_COMMAND} label="Salin perintah" copiedLabel="Tersalin!" />
        </div>
      </div>

      <div ref={scrollRef} className={`${height} overflow-y-auto p-4 font-mono text-[12.5px] leading-[1.75] sm:text-[13px]`}>
        <div aria-live="off">
          {SCRIPT.slice(0, count).map((line, index) => (
            <div key={index} className={TONE_CLASS[line.tone]}>
              {line.text || "\u00A0"}
            </div>
          ))}
          {!finished ? (
            <div className="text-cyan-brand">
              <span className="caret align-middle" />
            </div>
          ) : null}
        </div>
      </div>
    </div>
  );
}
