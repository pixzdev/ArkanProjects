"use client";

import { useCallback, useEffect, useRef, useState } from "react";
import { Menu, X, Github } from "lucide-react";
import { NAV_LINKS, SITE } from "@/lib/site";
import { LogoLock } from "./Logo";

export default function Navbar() {
  const [scrolled, setScrolled] = useState(false);
  const [open, setOpen] = useState(false);
  const [active, setActive] = useState<string>("");
  const progressRef = useRef<HTMLDivElement>(null);
  const frame = useRef(0);

  /* Indikator progres baca — dimutasi langsung tanpa memicu render ulang */
  useEffect(() => {
    const onScroll = () => {
      if (frame.current) return;
      frame.current = requestAnimationFrame(() => {
        frame.current = 0;
        const doc = document.documentElement;
        const max = doc.scrollHeight - window.innerHeight;
        const ratio = max > 0 ? Math.min(1, Math.max(0, window.scrollY / max)) : 0;
        if (progressRef.current) {
          progressRef.current.style.transform = `scaleX(${ratio})`;
        }
        setScrolled(window.scrollY > 12);
      });
    };

    onScroll();
    window.addEventListener("scroll", onScroll, { passive: true });
    return () => {
      window.removeEventListener("scroll", onScroll);
      if (frame.current) cancelAnimationFrame(frame.current);
    };
  }, []);

  /* Sorot menu sesuai bagian yang sedang dilihat */
  useEffect(() => {
    const sections = NAV_LINKS.map((link) =>
      document.querySelector<HTMLElement>(link.href),
    ).filter((el): el is HTMLElement => Boolean(el));

    if (!sections.length || !("IntersectionObserver" in window)) return;

    const observer = new IntersectionObserver(
      (entries) => {
        const visible = entries
          .filter((entry) => entry.isIntersecting)
          .sort((a, b) => b.intersectionRatio - a.intersectionRatio)[0];
        if (visible) setActive(`#${visible.target.id}`);
      },
      { rootMargin: "-45% 0px -50% 0px", threshold: [0, 0.25, 0.5, 1] },
    );

    sections.forEach((section) => observer.observe(section));
    return () => observer.disconnect();
  }, []);

  /* Kunci scroll saat menu mobile terbuka */
  useEffect(() => {
    document.body.style.overflow = open ? "hidden" : "";
    return () => {
      document.body.style.overflow = "";
    };
  }, [open]);

  const close = useCallback(() => setOpen(false), []);

  return (
    <header className="fixed inset-x-0 top-0 z-50">
      {/* Garis progres halaman */}
      <div className="absolute inset-x-0 top-0 h-px bg-white/5">
        <div
          ref={progressRef}
          className="h-full origin-left scale-x-0 bg-gradient-to-r from-cyan-brand via-emerald-brand to-violet-brand"
        />
      </div>

      <div
        className={`transition-all duration-300 ${
          scrolled ? "glass border-b border-white/[0.06] shadow-[0_18px_40px_-32px_rgba(0,0,0,0.9)]" : ""
        }`}
      >
        <nav className="shell flex h-16 items-center justify-between gap-4" aria-label="Navigasi utama">
          <a href="#atas" className="shrink-0" aria-label="ArkanProjects — kembali ke atas">
            <LogoLock />
          </a>

          <ul className="hidden items-center gap-0.5 lg:flex">
            {NAV_LINKS.map((link) => (
              <li key={link.href}>
                <a
                  href={link.href}
                  className={`rounded-full px-3 py-2 text-[13px] transition-colors ${
                    active === link.href
                      ? "bg-white/[0.06] text-cyan-brand"
                      : "text-slate-400 hover:bg-white/[0.04] hover:text-slate-100"
                  }`}
                >
                  {link.label}
                </a>
              </li>
            ))}
          </ul>

          <div className="hidden items-center gap-2 lg:flex">
            <a
              href={SITE.github}
              target="_blank"
              rel="noopener noreferrer"
              className="btn btn-ghost !px-3"
              aria-label="Repositori GitHub ArkanProjects"
            >
              <Github className="h-4 w-4" />
              <span>GitHub</span>
            </a>
            <a href="#instalasi" className="btn btn-primary">
              Instal Sekarang
            </a>
          </div>

          <button
            type="button"
            onClick={() => setOpen((value) => !value)}
            className="inline-flex h-10 w-10 items-center justify-center rounded-xl border border-white/10 text-slate-300 transition-colors hover:text-white lg:hidden"
            aria-expanded={open}
            aria-controls="menu-mobile"
            aria-label={open ? "Tutup menu" : "Buka menu"}
          >
            {open ? <X className="h-5 w-5" /> : <Menu className="h-5 w-5" />}
          </button>
        </nav>
      </div>

      {/* Menu mobile */}
      <div
        id="menu-mobile"
        className={`glass overflow-hidden border-b border-white/[0.06] transition-[max-height,opacity] duration-300 lg:hidden ${
          open ? "max-h-[80vh] opacity-100" : "max-h-0 opacity-0"
        }`}
      >
        <div className="shell flex flex-col gap-1 py-4">
          {NAV_LINKS.map((link) => (
            <a
              key={link.href}
              href={link.href}
              onClick={close}
              className="rounded-xl px-3 py-3 text-sm text-slate-300 transition-colors hover:bg-white/[0.04] hover:text-white"
            >
              {link.label}
            </a>
          ))}
          <div className="mt-2 grid grid-cols-2 gap-2 border-t border-white/[0.06] pt-4">
            <a
              href={SITE.github}
              target="_blank"
              rel="noopener noreferrer"
              className="btn btn-ghost"
              onClick={close}
            >
              <Github className="h-4 w-4" />
              GitHub
            </a>
            <a href="#instalasi" className="btn btn-primary" onClick={close}>
              Instal Sekarang
            </a>
          </div>
        </div>
      </div>
    </header>
  );
}
