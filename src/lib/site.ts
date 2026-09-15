/**
 * Satu sumber kebenaran untuk konten situs.
 * Ubah data di sini — komponen tidak perlu disentuh.
 */

export const SITE = {
  name: "ArkanProjects",
  tagline: "Pterodactyl All-in-One Installer",
  description:
    "Instal Pterodactyl Panel & Wings dalam satu perintah. Multi-OS, SSL otomatis, CLI modern, plus manajemen server lewat perintah arkan.",
  url: "https://arkanprojects.vercel.app",
  github: "https://github.com/PixZ19/ArkanProjects",
  installer: "https://arkanprojects.vercel.app/installer/pterodactyl.sh",
  installerVersion: "2.0.0",
  panelVersion: "1.15.x",
  wingsVersion: "1.13.x",
  phpVersion: "8.3",
  mariadbVersion: "11.4 LTS",
  license: "GPL-3.0",
} as const;

export const INSTALL_COMMAND = `bash <(curl -s ${SITE.installer})`;

export const NAV_LINKS = [
  { label: "Fitur", href: "#fitur" },
  { label: "Instalasi", href: "#instalasi" },
  { label: "CLI", href: "#cli" },
  { label: "Alur", href: "#alur" },
  { label: "Teknologi", href: "#teknologi" },
  { label: "OS", href: "#kompatibilitas" },
  { label: "FAQ", href: "#faq" },
] as const;

export const HERO_STATS = [
  { value: "10", label: "Sistem operasi didukung" },
  { value: "1", label: "Perintah untuk semua" },
  { value: "±6", label: "Menit instalasi Panel" },
  { value: "0", label: "Konfigurasi manual" },
] as const;

export interface Feature {
  icon: string;
  title: string;
  description: string;
  accent: string;
}

export const FEATURES: Feature[] = [
  {
    icon: "Package",
    title: "All-in-One Installer",
    description:
      "Panel dan Wings diinstal dari satu script. Pilih mode instalasi, sisanya dikerjakan otomatis tanpa perlu menjalankan installer terpisah.",
    accent: "var(--color-cyan-brand)",
  },
  {
    icon: "Terminal",
    title: "Mode Unattended",
    description:
      "Dukungan flag CLI (--panel, --wings, --fqdn, --email, --yes) sehingga instalasi bisa dijalankan non-interaktif untuk otomasi CI atau provisioning massal.",
    accent: "var(--color-emerald-brand)",
  },
  {
    icon: "Wrench",
    title: "Perintah arkan",
    description:
      "CLI manajemen terpasang di /usr/local/bin/arkan: status, update, backup, restore, logs, restart, doctor, hingga uninstall.",
    accent: "var(--color-violet-brand)",
  },
  {
    icon: "ShieldCheck",
    title: "SSL Otomatis",
    description:
      "Let's Encrypt dikonfigurasi lengkap dengan verifikasi DNS, redirect HTTP ke HTTPS, HSTS, dan pembaruan sertifikat otomatis via systemd timer.",
    accent: "var(--color-pink-brand)",
  },
  {
    icon: "Flame",
    title: "Firewall Terkelola",
    description:
      "UFW untuk Ubuntu/Debian dan FirewallD untuk Rocky/AlmaLinux. Hanya port yang dibutuhkan panel, Wings, SFTP, dan DB yang dibuka.",
    accent: "var(--color-cyan-brand)",
  },
  {
    icon: "Container",
    title: "Docker Siap Wings",
    description:
      "Docker CE dipasang dari repository resmi sesuai distro (bug repo Ubuntu diperbaiki), plus service systemd dan pemeriksaan virtualisasi container.",
    accent: "var(--color-emerald-brand)",
  },
  {
    icon: "Database",
    title: "MariaDB + Redis",
    description:
      "MariaDB LTS dari repository resmi dan Redis untuk cache, session, dan queue. Password database dibuat acak dengan kualitas kriptografis.",
    accent: "var(--color-violet-brand)",
  },
  {
    icon: "RefreshCw",
    title: "Update & Backup",
    description:
      "Menu update panel/wings dengan backup otomatis sebelum migrasi, ditambah snapshot database dan folder panel ke /var/backups/arkanprojects.",
    accent: "var(--color-pink-brand)",
  },
  {
    icon: "Activity",
    title: "Doctor & Log",
    description:
      "Pemeriksaan kesehatan sistem (service, socket, koneksi DB, DNS) dan log terstruktur di /var/log/arkanprojects-installer.log dengan rotasi otomatis.",
    accent: "var(--color-cyan-brand)",
  },
];

export interface CliCommand {
  command: string;
  description: string;
}

export const CLI_COMMANDS: CliCommand[] = [
  { command: "arkan status", description: "Ringkasan kesehatan service Panel, Wings, queue worker, dan database." },
  { command: "arkan doctor", description: "Diagnosa menyeluruh: versi OS, PHP, socket FPM, koneksi DB, port, dan DNS." },
  { command: "arkan update panel", description: "Backup otomatis lalu update Panel ke rilis terbaru." },
  { command: "arkan update wings", description: "Perbarui binary Wings dan restart daemon." },
  { command: "arkan backup", description: "Snapshot database + file panel ke /var/backups/arkanprojects." },
  { command: "arkan restore <file>", description: "Pulihkan panel dari file backup yang dipilih." },
  { command: "arkan logs panel", description: "Ikuti log Laravel, Nginx, atau queue worker secara real-time." },
  { command: "arkan uninstall", description: "Hapus Panel/Wings dengan konfirmasi berlapis dan opsi simpan database." },
];

export interface InstallMode {
  id: string;
  label: string;
  command: string;
  note: string;
}

export const INSTALL_MODES: InstallMode[] = [
  {
    id: "interactive",
    label: "Interaktif",
    command: INSTALL_COMMAND,
    note: "Wizard menanyakan konfigurasi satu per satu — cocok untuk instalasi pertama.",
  },
  {
    id: "panel",
    label: "Panel & Wings",
    command: `${INSTALL_COMMAND} --both --yes`,
    note: "Panel + Wings pada satu mesin, seluruh pilihan memakai nilai default aman.",
  },
  {
    id: "wings",
    label: "Wings (node)",
    command: `bash <(curl -s ${SITE.installer}) --wings --yes`,
    note: "Hanya daemon Wings — untuk node tambahan yang dikelola Panel terpisah.",
  },
  {
    id: "unattended",
    label: "Unattended",
    command: `bash <(curl -s ${SITE.installer}) --panel --fqdn panel.domain.com --email admin@domain.com --yes --firewall --ssl`,
    note: "Semua parameter dikirim lewat flag, tanpa satu pun pertanyaan. Siap untuk otomasi.",
  },
];

export interface Step {
  icon: string;
  title: string;
  description: string;
  duration: string;
  accent: string;
}

export const STEPS: Step[] = [
  {
    icon: "Cpu",
    title: "Deteksi sistem",
    description:
      "Script membaca distro, versi, arsitektur CPU, RAM, virtualisasi, dan kapasitas disk. Distribusi yang tidak didukung dihentikan lebih awal.",
    duration: "< 5 detik",
    accent: "var(--color-cyan-brand)",
  },
  {
    icon: "Settings",
    title: "Konfigurasi",
    description:
      "Lewat wizard atau flag CLI: database, FQDN, email, akun admin, opsi SSL dan firewall. FQDN serta DNS diverifikasi sebelum menyentuh sistem.",
    duration: "30 detik",
    accent: "var(--color-emerald-brand)",
  },
  {
    icon: "Package",
    title: "Dependensi",
    description:
      "PHP 8.3, MariaDB LTS, Nginx, Redis, Composer, dan paket pendukung lain dipasang dari repository resmi sesuai distribusi.",
    duration: "2–3 menit",
    accent: "var(--color-violet-brand)",
  },
  {
    icon: "Server",
    title: "Instalasi Panel",
    description:
      "Panel diunduh, Composer install, database dibuat, environment & migrasi dijalankan, akun admin pertama dibuat otomatis.",
    duration: "±3 menit",
    accent: "var(--color-pink-brand)",
  },
  {
    icon: "Lock",
    title: "Web server & SSL",
    description:
      "Nginx dikonfigurasi dengan TLS modern dan security header, Certbot menerbitkan sertifikat, queue worker dan cron diaktifkan.",
    duration: "±1 menit",
    accent: "var(--color-cyan-brand)",
  },
  {
    icon: "Container",
    title: "Wings & node",
    description:
      "Docker CE, binary Wings, dan service systemd disiapkan. Tinggal tempel config.yml dari Panel dan jalankan node.",
    duration: "±2 menit",
    accent: "var(--color-emerald-brand)",
  },
];

export interface TechItem {
  icon: string;
  name: string;
  version: string;
  description: string;
  accent: string;
}

export const TECH_STACK: TechItem[] = [
  { icon: "Code2", name: "PHP", version: "8.3", description: "Runtime Panel dengan FPM pool yang dituning sesuai RAM server.", accent: "var(--color-cyan-brand)" },
  { icon: "Database", name: "MariaDB", version: "11.4 LTS", description: "Database Panel dari repository resmi MariaDB.", accent: "var(--color-emerald-brand)" },
  { icon: "Globe", name: "Nginx", version: "1.24+", description: "Reverse proxy, TLS 1.2/1.3, HTTP/2, dan security header.", accent: "var(--color-violet-brand)" },
  { icon: "Zap", name: "Redis", version: "7.x+", description: "Cache, session, dan queue driver untuk Panel.", accent: "var(--color-pink-brand)" },
  { icon: "Container", name: "Docker CE", version: "Latest", description: "Runtime container yang dipakai Wings untuk tiap game server.", accent: "var(--color-cyan-brand)" },
  { icon: "Package", name: "Composer", version: "2.x", description: "Dependency manager PHP untuk memasang paket Panel.", accent: "var(--color-emerald-brand)" },
  { icon: "ShieldCheck", name: "Certbot", version: "Let's Encrypt", description: "Penerbitan & perpanjangan sertifikat SSL otomatis.", accent: "var(--color-violet-brand)" },
  { icon: "Cpu", name: "Node.js", version: "20 LTS · opsional", description: "Hanya dipasang bila memakai flag --with-node, untuk build aset Panel atau addon.", accent: "var(--color-pink-brand)" },
  { icon: "Terminal", name: "Bash 4+", version: "Pure shell", description: "Tanpa dependensi runtime tambahan, hanya shell dan paket sistem.", accent: "var(--color-cyan-brand)" },
];

export interface OSItem {
  name: string;
  codename: string;
  version: string;
  archs: string[];
  status: "LTS" | "Stable";
  accent: string;
}

export const OS_LIST: OSItem[] = [
  { name: "Ubuntu", codename: "Jammy Jellyfish", version: "22.04 LTS", archs: ["amd64", "arm64"], status: "LTS", accent: "#f97316" },
  { name: "Ubuntu", codename: "Noble Numbat", version: "24.04 LTS", archs: ["amd64", "arm64"], status: "LTS", accent: "#f97316" },
  { name: "Debian", codename: "Bullseye", version: "11", archs: ["amd64"], status: "Stable", accent: "#f472b6" },
  { name: "Debian", codename: "Bookworm", version: "12", archs: ["amd64"], status: "Stable", accent: "#f472b6" },
  { name: "Debian", codename: "Trixie", version: "13", archs: ["amd64"], status: "Stable", accent: "#f472b6" },
  { name: "Rocky Linux", codename: "Green Obsidian", version: "8", archs: ["amd64"], status: "LTS", accent: "#34d399" },
  { name: "Rocky Linux", codename: "Blue Onyx", version: "9", archs: ["amd64"], status: "LTS", accent: "#34d399" },
  { name: "AlmaLinux", codename: "Sapphire Caracal", version: "8", archs: ["amd64"], status: "LTS", accent: "#8b5cf6" },
  { name: "AlmaLinux", codename: "Purple Sultan", version: "9", archs: ["amd64"], status: "LTS", accent: "#8b5cf6" },
];

export const REQUIREMENTS = [
  { label: "CPU", value: "1 core", hint: "Panel", accent: "var(--color-cyan-brand)" },
  { label: "RAM", value: "2 GB", hint: "Panel · +1 GB per node Wings", accent: "var(--color-emerald-brand)" },
  { label: "Disk", value: "20 GB", hint: "SSD disarankan", accent: "var(--color-violet-brand)" },
  { label: "Akses", value: "root", hint: "VPS / dedicated (bukan OpenVZ)", accent: "var(--color-pink-brand)" },
] as const;

export const COMPARE_ROWS = [
  { label: "Jumlah perintah", manual: "40+ perintah manual", arkan: "1 perintah" },
  { label: "Waktu instalasi", manual: "45–90 menit", arkan: "±6 menit" },
  { label: "Konfigurasi Nginx & SSL", manual: "Salin manual, rawan salah", arkan: "Otomatis + TLS modern" },
  { label: "Database & queue", manual: "Dibuat sendiri", arkan: "Otomatis (MariaDB + Redis)" },
  { label: "Firewall", manual: "Diatur manual", arkan: "UFW / FirewallD otomatis" },
  { label: "Update panel", manual: "Ikuti panduan, backup manual", arkan: "arkan update panel (backup dulu)" },
  { label: "Diagnosa masalah", manual: "Cek service satu per satu", arkan: "arkan doctor" },
];

export interface FaqItem {
  question: string;
  answer: string;
}

export const FAQ_ITEMS: FaqItem[] = [
  {
    question: "Apa bedanya Panel dan Wings?",
    answer:
      "Panel adalah antarmuka web tempat admin mengelola user, node, dan server. Wings adalah daemon yang berjalan di setiap node dan mengeksekusi game server di dalam container Docker. Satu Panel bisa mengelola banyak node Wings.",
  },
  {
    question: "Berapa spesifikasi minimum server?",
    answer:
      "Untuk Panel: 1 core CPU, 2 GB RAM, dan 20 GB disk. Untuk Wings: tambahan 1 GB RAM per node. Jika Panel dan Wings dijalankan di mesin yang sama, sediakan minimal 2 core CPU, 3 GB RAM, dan 30 GB disk. Untuk produksi, sesuaikan RAM dengan jumlah game server yang berjalan.",
  },
  {
    question: "Bisa diinstal tanpa domain?",
    answer:
      "Bisa. Panel tetap berjalan dengan IP address langsung, tetapi fitur SSL otomatis memerlukan domain yang DNS-nya sudah mengarah ke IP server. Jika memakai IP, pilih opsi tanpa SSL atau pasang sertifikat sendiri, lalu setel ulang Nginx.",
  },
  {
    question: "Apakah aman menjalankan ulang script?",
    answer:
      "Ya. Installer bersifat idempotent: instalasi yang sudah ada dideteksi lebih dulu, dan setiap langkah diberi konfirmasi sebelum menimpa data. Sebelum operasi update, script membuat backup otomatis terlebih dahulu.",
  },
  {
    question: "Bagaimana cara update Panel atau Wings?",
    answer:
      "Gunakan perintah arkan update panel atau arkan update wings. Script akan membackup database dan file panel, mengunduh rilis terbaru, menjalankan migrasi serta cache rebuild, lalu merestart service yang diperlukan.",
  },
  {
    question: "Apakah bisa dipakai untuk otomasi?",
    answer:
      "Bisa. Semua pertanyaan wizard punya padanan flag CLI, misalnya --panel --fqdn panel.domain.com --email admin@domain.com --yes --ssl --firewall. Tambahkan --dry-run untuk memeriksa rencana instalasi tanpa mengubah sistem.",
  },
  {
    question: "Bagaimana jika instalasi gagal di tengah jalan?",
    answer:
      "Semua langkah tercatat di /var/log/arkanprojects-installer.log beserta timestamp. Jalankan arkan doctor untuk memeriksa service, socket PHP-FPM, koneksi database, DNS, dan port. Karena script idempotent, instalasi bisa dilanjutkan dengan menjalankannya kembali.",
  },
  {
    question: "Distribusi apa saja yang didukung?",
    answer:
      "Ubuntu 22.04/24.04 LTS, Debian 11/12/13, Rocky Linux 8/9, dan AlmaLinux 8/9 pada arsitektur amd64 maupun arm64 (Ubuntu). Disarankan memakai VPS KVM; sistem berbasis container seperti OpenVZ biasanya tidak mendukung Docker sehingga Wings tidak akan berjalan.",
  },
];

export const TEAM = [
  { name: "Muhammad Rafif Rianto C.Ps", role: "Lead Developer", accent: "var(--color-cyan-brand)" },
  { name: "Faturrahman Al Rizky", role: "Backend Developer", accent: "var(--color-emerald-brand)" },
  { name: "Akhbar Alfiansyah", role: "UI/UX Designer", accent: "var(--color-violet-brand)" },
] as const;

export const TIMELINE = [
  { version: "v1.0", date: "2025", description: "Panel + Wings, SSL, dan firewall dalam satu script." },
  { version: "v2.0", date: "2026", description: "Mode unattended, CLI arkan, backup & restore, doctor, log rotation." },
  { version: "v2.1", date: "Rencana", description: "Addon game, tema panel, dan manajemen multi-node." },
] as const;

export const SOURCES = [
  {
    title: "pterodactyl-installer",
    description: "Installer resmi komunitas — referensi arsitektur modular dan alur instalasi.",
    url: "https://github.com/pterodactyl-installer/pterodactyl-installer",
    meta: "Shell · MIT",
  },
  {
    title: "pterodactyl/panel",
    description: "Sumber rilis Panel yang diunduh installer, selalu versi terbaru.",
    url: "https://github.com/pterodactyl/panel",
    meta: "PHP · MIT",
  },
  {
    title: "pterodactyl/wings",
    description: "Daemon node yang menjalankan container game server di setiap mesin.",
    url: "https://github.com/pterodactyl/wings",
    meta: "Go · MIT",
  },
] as const;
