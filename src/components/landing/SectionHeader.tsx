import { Icon } from "./Icon";

export default function SectionHeader({
  eyebrow,
  eyebrowIcon,
  title,
  lead,
  align = "center",
  accent = "var(--color-cyan-brand)",
}: {
  eyebrow: string;
  eyebrowIcon?: string;
  title: React.ReactNode;
  lead?: string;
  align?: "center" | "left";
  accent?: string;
}) {
  const isCenter = align === "center";

  return (
    <div
      className={`flex flex-col ${isCenter ? "items-center text-center" : "items-start text-left"}`}
      data-reveal
    >
      <span className="eyebrow" style={{ color: accent }}>
        {eyebrowIcon ? (
          <Icon name={eyebrowIcon} className="h-3.5 w-3.5" />
        ) : (
          <span className="dot-live" />
        )}
        {eyebrow}
      </span>

      <h2 className="section-title mt-4 text-balance text-white">{title}</h2>

      {lead ? (
        <p className={`lead mt-4 text-pretty ${isCenter ? "max-w-2xl" : "max-w-2xl"}`}>
          {lead}
        </p>
      ) : null}
    </div>
  );
}
