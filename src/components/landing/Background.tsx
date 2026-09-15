/**
 * Latar belakang situs — murni CSS (tanpa canvas, tanpa request jaringan).
 * Blob aurora memakai animasi transform/opacity yang ramah GPU.
 */
export default function Background() {
  return (
    <div className="pointer-events-none fixed inset-0 -z-10 overflow-hidden" aria-hidden="true">
      {/* Basis gelap + gradasi lembut */}
      <div className="absolute inset-0 bg-ink-950" />
      <div className="absolute inset-0 bg-[radial-gradient(120%_80%_at_50%_-10%,rgba(34,211,238,0.10),transparent_60%)]" />
      <div className="absolute inset-0 bg-[radial-gradient(90%_60%_at_85%_110%,rgba(139,92,246,0.10),transparent_60%)]" />

      {/* Aurora blobs */}
      <div
        className="aurora top-[-12%] left-[-8%] h-[38rem] w-[38rem] animate-drift bg-[radial-gradient(circle,rgba(34,211,238,0.30),transparent_65%)]"
      />
      <div
        className="aurora top-[18%] right-[-14%] h-[32rem] w-[32rem] animate-float-slow bg-[radial-gradient(circle,rgba(139,92,246,0.28),transparent_65%)]"
        style={{ animationDelay: "-6s" }}
      />
      <div
        className="aurora bottom-[-16%] left-[22%] h-[34rem] w-[34rem] animate-drift bg-[radial-gradient(circle,rgba(52,211,153,0.22),transparent_65%)]"
        style={{ animationDelay: "-12s" }}
      />

      {/* Grid halus */}
      <div className="grid-lines opacity-70" />

      {/* Vignette bawah */}
      <div className="absolute inset-x-0 bottom-0 h-64 bg-gradient-to-t from-ink-950 to-transparent" />
    </div>
  );
}
