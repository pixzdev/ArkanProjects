import {
  Activity,
  ArrowRight,
  ArrowUpRight,
  Box,
  Check,
  CheckCircle2,
  ChevronDown,
  Clock,
  Code2,
  Container,
  Copy,
  Cpu,
  Database,
  Download,
  ExternalLink,
  Flame,
  Github,
  Globe,
  HardDrive,
  Heart,
  Layers,
  Lock,
  Menu,
  Package,
  RefreshCw,
  Scale,
  Server,
  Settings,
  Shield,
  ShieldCheck,
  Sparkles,
  Star,
  Terminal,
  Users,
  Wrench,
  X,
  Zap,
  type LucideIcon,
} from "lucide-react";

/**
 * Registry ikon — hanya ikon yang dipakai yang ikut ter-bundle
 * sehingga tidak ada tambahan berat pada bundle JS.
 */
const registry: Record<string, LucideIcon> = {
  Activity,
  ArrowRight,
  ArrowUpRight,
  Box,
  Check,
  CheckCircle2,
  ChevronDown,
  Clock,
  Code2,
  Container,
  Copy,
  Cpu,
  Database,
  Download,
  ExternalLink,
  Flame,
  Github,
  Globe,
  HardDrive,
  Heart,
  Layers,
  Lock,
  Menu,
  Package,
  RefreshCw,
  Scale,
  Server,
  Settings,
  Shield,
  ShieldCheck,
  Sparkles,
  Star,
  Terminal,
  Users,
  Wrench,
  X,
  Zap,
};

export function Icon({
  name,
  className,
  style,
}: {
  name: string;
  className?: string;
  style?: React.CSSProperties;
}) {
  const Cmp = registry[name] ?? Sparkles;
  return <Cmp className={className} style={style} aria-hidden="true" />;
}
