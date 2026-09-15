/**
 * Logo ArkanProjects — SVG inline (tanpa permintaan gambar tambahan).
 * Dipakai di navbar, footer, dan sebagai ikon situs.
 */
export function LogoMark({ className = "h-8 w-8" }: { className?: string }) {
  return (
    <svg viewBox="0 0 32 32" className={className} role="img" aria-label="ArkanProjects">
      <defs>
        <linearGradient id="arkan-grad" x1="0" y1="0" x2="1" y2="1">
          <stop offset="0%" stopColor="#22d3ee" />
          <stop offset="55%" stopColor="#34d399" />
          <stop offset="100%" stopColor="#8b5cf6" />
        </linearGradient>
      </defs>
      <rect x="1" y="1" width="30" height="30" rx="9" fill="url(#arkan-grad)" opacity="0.13" />
      <rect x="1.75" y="1.75" width="28.5" height="28.5" rx="8.5" fill="none" stroke="url(#arkan-grad)" strokeWidth="1.6" />
      <path
        d="M10.5 11.5 L15 16 L10.5 20.5"
        fill="none"
        stroke="url(#arkan-grad)"
        strokeWidth="2.4"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <path d="M17.5 20.5 h4.5" stroke="#34d399" strokeWidth="2.4" strokeLinecap="round" />
    </svg>
  );
}

export function LogoLock({
  className = "",
  markClass = "h-8 w-8",
}: {
  className?: string;
  markClass?: string;
}) {
  return (
    <span className={`inline-flex items-center gap-2.5 ${className}`}>
      <LogoMark className={markClass} />
      <span className="text-[1.0625rem] font-semibold tracking-tight text-white">
        Arkan<span className="gradient-text">Projects</span>
      </span>
    </span>
  );
}
