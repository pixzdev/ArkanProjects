#!/usr/bin/env bash
# ============================================================================
#  ArkanProjects — Pterodactyl All-in-One Installer
#  Version: 2.0.0
#
#  Instalasi Pterodactyl Panel & Wings dalam satu perintah:
#    • Panel + Wings (satu mesin atau terpisah)
#    • Multi-OS: Ubuntu 22/24, Debian 11/12/13, Rocky 8/9, AlmaLinux 8/9
#    • SSL Let's Encrypt otomatis + perpanjangan otomatis
#    • Firewall (UFW / FirewallD), MariaDB LTS, Redis, Docker CE
#    • Mode unattended (flag CLI) untuk otomasi
#    • CLI manajemen "arkan" (status, doctor, update, backup, restore, logs)
#
#  Cara pakai:
#    bash <(curl -s https://arkanprojects.vercel.app/installer/pterodactyl.sh)
#    bash <(curl -s .../pterodactyl.sh) --both --fqdn panel.domain.com --email a@b.com --yes
#
#  Lisensi: GPL-3.0
#  Proyek : https://github.com/PixZ19/ArkanProjects
# ============================================================================

set -Eeuo pipefail

readonly ARKAN_VERSION="2.0.0"
readonly ARKAN_REPO="https://github.com/PixZ19/ArkanProjects"
readonly ARKAN_SELF_URL="https://arkanprojects.vercel.app/installer/pterodactyl.sh"
readonly ARKAN_HOME="/etc/arkanprojects"
readonly ARKAN_CONF="${ARKAN_HOME}/arkan.conf"
readonly ARKAN_BIN="/usr/local/bin/arkan"
readonly ARKAN_BACKUP_DIR="/var/backups/arkanprojects"
readonly ARKAN_LOG="/var/log/arkanprojects-installer.log"
readonly ARKAN_LOGROTATE="/etc/logrotate.d/arkanprojects"
readonly PANEL_DIR="/var/www/pterodactyl"
readonly WINGS_DIR="/etc/pterodactyl"
readonly WINGS_BIN="/usr/local/bin/wings"
readonly PANEL_DL_URL="https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz"
readonly WINGS_DL_BASE="https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_"
readonly MARIADB_REPO_SETUP="https://downloads.mariadb.com/MariaDB/mariadb_repo_setup"
readonly NODESOURCE_SETUP="https://deb.nodesource.com/setup_20.x"
readonly PHP_VERSION="8.3"
readonly NODE_MAJOR="20"

# ---------------------------- Opsi CLI ----------------------------

OPT_MODE=""              # panel | wings | both
OPT_FQDN=""
OPT_EMAIL=""
OPT_TIMEZONE=""
OPT_DB_NAME=""
OPT_DB_USER=""
OPT_DB_PASS=""
OPT_ADMIN_EMAIL=""
OPT_ADMIN_USER=""
OPT_ADMIN_PASS=""
OPT_ADMIN_FIRST=""
OPT_ADMIN_LAST=""
OPT_DBHOST_USER=""
OPT_DBHOST_PASS=""
OPT_DBHOST_HOST=""
OPT_ASSUME_YES=0
OPT_DRY_RUN=0
OPT_FIREWALL=""          # ya | tidak
OPT_SSL=""               # ya | tidak
OPT_ASSUME_SSL=""        # ya | tidak (SSL sudah dikonfigurasi manual)
OPT_DBHOST=""            # ya | tidak
OPT_WITH_NODE=0
OPT_UNINSTALL=0
OPT_COLOR="auto"

# ---------------------------- Status runtime ----------------------------

DRY_RUN=0
ASSUME_YES=0
HAS_TTY=0
USE_COLOR=0
LOG_FILE="$ARKAN_LOG"
INSTALL_START=$SECONDS
STEP_INDEX=0
STEP_TOTAL=0
TMP_DIR=""

OS_ID=""
OS_LIKE=""
OS_VER=""
OS_VER_MAJOR=""
OS_PRETTY=""
ARCH=""
PKG=""
PHP_SOCK=""
PHP_SERVICE=""
PHP_INI_DIR=""
WEB_USER=""
WEB_GROUP=""
MARIADB_SERVICE="mariadb"
REDIS_SERVICE="redis-server"
FIREWALL_KIND="ufw"
DB_HOST_LOCAL="127.0.0.1"
PANEL_VERSION=""
WINGS_VERSION=""
CONFIGURE_LETSENCRYPT=false
CONFIGURE_FIREWALL=false
CONFIGURE_DBHOST=false
CONFIGURE_DB_FIREWALL=false
INSTALL_PANEL=false
INSTALL_WINGS=false
PREEXISTING_PANEL=false
PREEXISTING_WINGS=false
RAM_MB=0
DISK_FREE_MB=0

# ============================================================================
#  TRAP & LOG
# ============================================================================

on_error() {
    local exit_code=$? line=${1:-?}
    printf '\n' >&2
    printf '  \033[1;31m✖ Gagal pada baris %s (exit %s)\033[0m\n' "$line" "$exit_code" >&2
    printf '  Lihat detail: %s\n' "$LOG_FILE" >&2
    printf '  Jalankan "arkan doctor" untuk memeriksa sistem.\n\n' >&2
    exit "$exit_code"
}
trap 'on_error $LINENO' ERR

log() {
    [ -n "$LOG_FILE" ] || return 0
    printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >>"$LOG_FILE" 2>/dev/null || true
}

# ============================================================================
#  TAMPILAN
# ============================================================================

setup_colors() {
    local want="${1:-auto}"
    if [ -n "${NO_COLOR:-}" ]; then USE_COLOR=0; return; fi
    case "$want" in
        never) USE_COLOR=0; return ;;
        always) USE_COLOR=1 ;;
        *)
            if [ "$HAS_TTY" -eq 1 ] && [ "${TERM:-dumb}" != "dumb" ]; then USE_COLOR=1; else USE_COLOR=0; fi
            ;;
    esac
}

c() {  # c <kode> <teks>
    if [ "$USE_COLOR" -eq 1 ]; then printf '\033[%sm%s\033[0m' "$1" "$2"; else printf '%s' "$2"; fi
}

C_DIM="2"; C_BOLD="1"; C_RED="31"; C_GREEN="32"; C_YELLOW="33"
C_BLUE="34"; C_MAGENTA="35"; C_CYAN="36"; C_WHITE="97"
C_NEON_CYAN="38;2;34;211;238"; C_NEON_GREEN="38;2;52;211;153"
C_NEON_VIOLET="38;2;139;92;246"; C_NEON_PINK="38;2;244;114;182"

hr() { printf '  %s\n' "$(c "$C_DIM" '───────────────────────────────────────────────────────────────')"; }
gap() { printf '\n'; }

brand_line() {
    printf '  %s %s\n' "$(c "1;${C_NEON_CYAN}" '◆')" "$(c "1;${C_NEON_CYAN}" 'ArkanProjects')"
}

banner() {
    gap
    brand_line
    printf '  %s\n' "$(c "$C_DIM" "Pterodactyl All-in-One Installer  v${ARKAN_VERSION}")"
    printf '  %s\n' "$(c "$C_DIM" "$ARKAN_REPO")"
    hr
    gap
}

ok()   { printf '  %s %s\n' "$(c "$C_NEON_GREEN" '✔')" "$*"; }
info() { printf '  %s %s\n' "$(c "$C_NEON_CYAN" '•')" "$*"; }
note() { printf '  %s %s\n' "$(c "$C_DIM" '·')" "$(c "$C_DIM" "$*")"; }
warn() { printf '  %s %s\n' "$(c "$C_YELLOW" '!')" "$(c "$C_YELLOW" "$*")"; }
bad()  { printf '  %s %s\n' "$(c "$C_RED" '✖')" "$(c "$C_RED" "$*")"; }

section() {
    gap
    printf '  %s\n' "$(c "1;${C_NEON_VIOLET}" "$1")"
    printf '  %s\n' "$(c "$C_DIM" '──────────────────────────────────────────────')"
}

step() {
    STEP_INDEX=$((STEP_INDEX + 1))
    gap
    printf '  %s %s\n' \
        "$(c "$C_NEON_CYAN" "[${STEP_INDEX}/${STEP_TOTAL}]")" \
        "$(c "$C_BOLD" "$1")"
}

elapsed_human() {
    local total=$1
    printf '%dm %02ds' "$((total / 60))" "$((total % 60))"
}

# Menjalankan perintah panjang dengan indikator progres.
# Output perintah masuk ke log; terminal hanya menampilkan status.
run_progress() {
    local label="$1"; shift
    if [ "$DRY_RUN" -eq 1 ]; then
        note "[dry-run] $label"
        return 0
    fi

    local frames='-\|/'
    if [ "${LC_ALL:-${LANG:-}}" != "" ] && locale charmap 2>/dev/null | grep -qi 'utf-\?8'; then
        frames='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    fi

    local start=$SECONDS pid rc=0 i=0
    "$@" >>"$LOG_FILE" 2>&1 &
    pid=$!

    while kill -0 "$pid" 2>/dev/null; do
        printf '\r  %s %s (%ss)   ' "$(c "$C_NEON_CYAN" "${frames:i%${#frames}:1}")" "$label" "$((SECONDS - start))"
        i=$((i + 1))
        sleep 0.12
    done
    wait "$pid" || rc=$?
    printf '\r%*s\r' "$((${#label} + 24))" ' '

    if [ "$rc" -eq 0 ]; then
        ok "$label"
    else
        bad "$label — cek $LOG_FILE"
    fi
    return "$rc"
}

ask() {  # ask <prompt> <default>
    local prompt="$1" def="${2:-}" answer=""
    if [ "$ASSUME_YES" -eq 1 ] && [ -n "$def" ]; then
        printf '%s' "$def"
        return 0
    fi
    printf '  %s %s' "$(c "$C_NEON_CYAN" '›')" "$prompt" >&2
    if [ -n "$def" ]; then printf ' %s' "$(c "$C_DIM" "[$def]")" >&2; fi
    printf ': ' >&2
    IFS= read -r answer || true
    [ -z "$answer" ] && answer="$def"
    printf '%s' "$answer"
}

ask_secret() {  # ask_secret <prompt> <default>
    local prompt="$1" def="${2:-}" answer=""
    if [ "$ASSUME_YES" -eq 1 ] && [ -n "$def" ]; then
        printf '%s' "$def"
        return 0
    fi
    printf '  %s %s: ' "$(c "$C_NEON_CYAN" '›')" "$prompt" >&2
    IFS= read -rs answer || true
    printf '\n' >&2
    [ -z "$answer" ] && answer="$def"
    printf '%s' "$answer"
}

ask_yesno() {  # ask_yesno <prompt> <default: y|n>
    local prompt="$1" def="${2:-n}" answer=""
    if [ "$ASSUME_YES" -eq 1 ]; then printf '%s' "$def"; return 0; fi
    printf '  %s %s %s ' "$(c "$C_NEON_CYAN" '›')" "$prompt" \
        "$(c "$C_DIM" "$([ "$def" = y ] && printf '(Y/n)' || printf '(y/N)')")" >&2
    IFS= read -r answer || true
    answer="${answer:-$def}"
    case "${answer,,}" in y|ya|yes) printf 'y' ;; *) printf 'n' ;; esac
}

die() { bad "$*"; gap; exit 1; }

# ============================================================================
#  BANTUAN & ARGUMEN
# ============================================================================

usage() {
    cat <<USAGE_EOF
ArkanProjects Installer v${ARKAN_VERSION} — Pterodactyl Panel & Wings

Penggunaan:
  bash <(curl -s ${ARKAN_SELF_URL}) [opsi]

Mode instalasi:
  --panel                Instal Panel saja
  --wings                Instal Wings saja (node)
  --both                 Instal Panel + Wings pada satu mesin

Parameter instalasi:
  --fqdn DOMAIN          FQDN Panel atau node (contoh: panel.domain.com)
  --email EMAIL          Email untuk Let's Encrypt dan Panel
  --timezone ZONA        Zona waktu (default: Asia/Jakarta)
  --db-name NAMA         Nama database Panel (default: panel)
  --db-user USER         User database Panel (default: pterodactyl)
  --db-pass PASS         Password database Panel (default: acak 64 karakter)
  --admin-email EMAIL    Email admin pertama (default: --email)
  --admin-user USER      Username admin (default: arkan)
  --admin-pass PASS      Password admin (default: acak 24 karakter)
  --admin-first NAMA     Nama depan admin (default: Arkan)
  --admin-last NAMA      Nama belakang admin (default: Projects)

Opsi tambahan:
  --ssl / --no-ssl       Aktifkan/matikan Let's Encrypt (default: tanya)
  --firewall / --no-firewall
                         Konfigurasi UFW/FirewallD (default: tanya)
  --assume-ssl           Tandai SSL sudah diatur sendiri (tanpa Certbot)
  --dbhost               Buat user database host untuk node Wings
  --with-node            Pasang Node.js ${NODE_MAJOR} LTS (butuh untuk build aset/addon)
  --uninstall            Hapus instalasi ArkanProjects di mesin ini

Perilaku:
  -y, --yes              Non-interaktif; gunakan nilai default & flag
  --dry-run              Tampilkan rencana instalasi tanpa mengubah sistem
  --color WHEN           auto|always|never
  -v, --version          Tampilkan versi installer
  -h, --help             Tampilkan bantuan ini

Contoh:
  # Interaktif
  bash <(curl -s ${ARKAN_SELF_URL})

  # Panel + Wings tanpa satu pun pertanyaan
  bash <(curl -s ${ARKAN_SELF_URL}) --both --fqdn panel.domain.com \\
       --email admin@domain.com --ssl --firewall --yes
USAGE_EOF
}

parse_args() {
    if [ "$#" -eq 0 ]; then
        return 0
    fi

    while [ "$#" -gt 0 ]; do
        case "$1" in
            --panel) OPT_MODE="panel" ;;
            --wings) OPT_MODE="wings" ;;
            --both|--all) OPT_MODE="both" ;;
            --fqdn) OPT_FQDN="${2:-}"; shift ;;
            --email) OPT_EMAIL="${2:-}"; shift ;;
            --timezone|--tz) OPT_TIMEZONE="${2:-}"; shift ;;
            --db-name) OPT_DB_NAME="${2:-}"; shift ;;
            --db-user) OPT_DB_USER="${2:-}"; shift ;;
            --db-pass) OPT_DB_PASS="${2:-}"; shift ;;
            --admin-email) OPT_ADMIN_EMAIL="${2:-}"; shift ;;
            --admin-user) OPT_ADMIN_USER="${2:-}"; shift ;;
            --admin-pass) OPT_ADMIN_PASS="${2:-}"; shift ;;
            --admin-first) OPT_ADMIN_FIRST="${2:-}"; shift ;;
            --admin-last) OPT_ADMIN_LAST="${2:-}"; shift ;;
            --dbhost-user) OPT_DBHOST_USER="${2:-}"; shift ;;
            --dbhost-pass) OPT_DBHOST_PASS="${2:-}"; shift ;;
            --dbhost-host) OPT_DBHOST_HOST="${2:-}"; shift ;;
            --dbhost) OPT_DBHOST="ya" ;;
            --no-dbhost) OPT_DBHOST="tidak" ;;
            --ssl) OPT_SSL="ya" ;;
            --no-ssl) OPT_SSL="tidak" ;;
            --assume-ssl) OPT_ASSUME_SSL="ya"; OPT_SSL="tidak" ;;
            --firewall) OPT_FIREWALL="ya" ;;
            --no-firewall) OPT_FIREWALL="tidak" ;;
            --with-node) OPT_WITH_NODE=1 ;;
            --uninstall) OPT_UNINSTALL=1 ;;
            -y|--yes|--unattended) OPT_ASSUME_YES=1 ;;
            --dry-run) OPT_DRY_RUN=1 ;;
            --color) OPT_COLOR="${2:-auto}"; shift ;;
            -v|--version) printf 'ArkanProjects Installer v%s\n' "$ARKAN_VERSION"; exit 0 ;;
            -h|--help) usage; exit 0 ;;
            *)
                if [[ "$1" == *=* ]]; then
                    # dukung --key=value
                    local key="${1%%=*}" val="${1#*=}"
                    set -- "$key" "$val" "${@:2}"
                    continue
                fi
                bad "Opsi tidak dikenal: $1"
                gap
                usage
                exit 2
                ;;
        esac
        shift
    done
}

# ============================================================================
#  UTILITAS
# ============================================================================

require_root() {
    if [ "$DRY_RUN" -eq 1 ]; then
        if [ "$(id -u)" -ne 0 ]; then
            warn "Dry-run dijalankan tanpa root — hanya menampilkan rencana."
        fi
        return 0
    fi
    if [ "${ARKAN_ASSUME_ROOT:-0}" = "1" ]; then
        return 0
    fi
    if [ "$(id -u)" -ne 0 ]; then
        die "Script harus dijalankan sebagai root. Contoh: sudo bash <(curl -s ${ARKAN_SELF_URL})"
    fi
}

need_cmd() { command -v "$1" >/dev/null 2>&1; }

gen_passwd() {
    local length="${1:-32}" charset='A-Za-z0-9!#%*+,-./:=?@_'
    local out
    out=$(head -c 4096 /dev/urandom | LC_ALL=C tr -dc "$charset" | head -c "$length" || true)
    printf '%s' "$out"
}

is_ip() {
    local ip="$1"
    [[ "$ip" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] && return 0
    [[ "$ip" =~ ^[0-9a-fA-F:]+$ && "$ip" == *:* ]] && return 0
    return 1
}

is_email() {
    [[ "$1" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]
}

is_fqdn() {
    local name="$1"
    is_ip "$name" && return 1
    [ "$name" = "localhost" ] && return 1
    [[ "$name" =~ ^([A-Za-z0-9]([A-Za-z0-9-]*[A-Za-z0-9])?\.)+[A-Za-z]{2,}$ ]]
}

cleanup() {
    [ -n "$TMP_DIR" ] && [ -d "$TMP_DIR" ] && rm -rf "$TMP_DIR"
    return 0
}
trap 'cleanup' EXIT

download() {  # download <url> <dest>
    local url="$1" dest="$2"
    if need_cmd curl; then
        curl -fsSL --retry 3 --retry-delay 2 --connect-timeout 15 -o "$dest" "$url"
    else
        wget -q -O "$dest" "$url"
    fi
}

latest_release() {  # latest_release <owner/repo>
    local repo="$1" tag=""
    if need_cmd curl; then
        tag=$(curl -fsSL --connect-timeout 10 --retry 2 "https://api.github.com/repos/${repo}/releases/latest" 2>/dev/null \
            | grep -m1 '"tag_name"' | sed -E 's/.*"tag_name": *"([^"]+)".*/\1/' || true)
    fi
    printf '%s' "$tag"
}

write_stdin() { local dest="$1"; cat >"$dest"; }

# ============================================================================
#  DETEKSI SISTEM
# ============================================================================

detect_os() {
    if [ -r /etc/os-release ]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        OS_ID="$(printf '%s' "${ID:-}" | tr '[:upper:]' '[:lower:]')"
        OS_LIKE="$(printf '%s' "${ID_LIKE:-}" | tr '[:upper:]' '[:lower:]')"
        OS_VER="${VERSION_ID:-}"
        OS_PRETTY="${PRETTY_NAME:-${ID:-unknown}}"
    elif [ -r /etc/debian_version ]; then
        OS_ID="debian"; OS_VER="$(cat /etc/debian_version)"; OS_PRETTY="Debian $OS_VER"
    else
        die "Tidak dapat mendeteksi sistem operasi (cari /etc/os-release)."
    fi

    OS_VER_MAJOR="${OS_VER%%.*}"

    case "$(uname -m)" in
        x86_64|amd64) ARCH="amd64" ;;
        aarch64|arm64) ARCH="arm64" ;;
        *) die "Arsitektur $(uname -m) belum didukung. Hanya amd64 dan arm64." ;;
    esac

    case "$OS_ID" in
        ubuntu|debian)
            PKG="apt"
            WEB_USER="www-data"; WEB_GROUP="www-data"
            PHP_SOCK="/run/php/php${PHP_VERSION}-fpm.sock"
            PHP_SERVICE="php${PHP_VERSION}-fpm"
            PHP_INI_DIR="/etc/php/${PHP_VERSION}/fpm"
            REDIS_SERVICE="redis-server"
            FIREWALL_KIND="ufw"
            MARIADB_SERVICE="mariadb"
            ;;
        rocky|almalinux|rhel|centos)
            PKG="dnf"
            WEB_USER="nginx"; WEB_GROUP="nginx"
            PHP_SOCK="/var/run/php-fpm/pterodactyl.sock"
            PHP_SERVICE="php-fpm"
            PHP_INI_DIR="/etc/php-fpm.d"
            REDIS_SERVICE="redis"
            FIREWALL_KIND="firewalld"
            MARIADB_SERVICE="mariadb"
            if [ "$OS_ID" = "centos" ] || [ "$OS_ID" = "rhel" ]; then
                OS_ID="almalinux"
                note "RHEL/CentOS terdeteksi — diperlakukan sebagai keluarga Rocky/AlmaLinux."
            fi
            ;;
        *)
            die "Distribusi '${OS_ID}' belum didukung. Didukung: Ubuntu 22/24, Debian 11/12/13, Rocky 8/9, AlmaLinux 8/9."
            ;;
    esac

    # Validasi versi
    local supported=false
    case "$OS_ID" in
        ubuntu) [ "$OS_VER_MAJOR" = "22" ] || [ "$OS_VER_MAJOR" = "24" ] && supported=true ;;
        debian) [ "$OS_VER_MAJOR" -ge 11 ] 2>/dev/null && [ "$OS_VER_MAJOR" -le 13 ] 2>/dev/null && supported=true ;;
        rocky|almalinux) [ "$OS_VER_MAJOR" = "8" ] || [ "$OS_VER_MAJOR" = "9" ] && supported=true ;;
    esac
    [ "$supported" = true ] || warn "Versi ${OS_PRETTY} di luar daftar yang diuji — instalasi tetap dilanjutkan."

    # Sumber daya
    RAM_MB=$(awk '/MemTotal/ {printf "%d", $2/1024}' /proc/meminfo 2>/dev/null || printf '0')
    DISK_FREE_MB=$(df -Pm / | awk 'NR==2 {print $4}' 2>/dev/null || printf '0')

    info "Sistem: $(c "$C_BOLD" "$OS_PRETTY") · ${ARCH} · ${RAM_MB} MB RAM · $(df -Ph / | awk 'NR==2 {print $4}') bebas"
    log "Deteksi OS: ${OS_PRETTY} (${OS_ID} ${OS_VER}) arch=${ARCH} ram=${RAM_MB}MB"
}

preflight_checks() {
    if [ "$RAM_MB" -gt 0 ] && [ "$RAM_MB" -lt 1800 ] && [ "${INSTALL_PANEL:-false}" = "true" ]; then
        warn "RAM terdeteksi ${RAM_MB} MB. Panel disarankan minimal 2 GB RAM."
        local swap_total
        swap_total=$(awk '/SwapTotal/ {printf "%d", $2/1024}' /proc/meminfo 2>/dev/null || printf '0')
        if [ "$swap_total" -lt 1024 ] && [ "$DRY_RUN" -eq 0 ]; then
            local buat
            buat=$(ask_yesno "Tambahkan swap 2 GB untuk stabilitas?" y)
            if [ "$buat" = y ]; then
                run_progress "Membuat swap 2 GB" bash -c '
                    fallocate -l 2G /swapfile || dd if=/dev/zero of=/swapfile bs=1M count=2048 status=none
                    chmod 600 /swapfile && mkswap /swapfile >/dev/null && swapon /swapfile
                    grep -q "/swapfile" /etc/fstab || echo "/swapfile none swap sw 0 0" >> /etc/fstab
                '
            fi
        fi
    fi

    if [ "$DISK_FREE_MB" -gt 0 ] && [ "$DISK_FREE_MB" -lt 5000 ]; then
        warn "Ruang disk tersisa hanya $((DISK_FREE_MB / 1024)) GB. Panel memerlukan minimal 20 GB."
    fi

    if need_cmd systemd-detect-virt; then
        local virt
        virt=$(systemd-detect-virt 2>/dev/null || printf 'none')
        case "$virt" in
            openvz|lxc|docker|podman)
                warn "Virtualisasi '${virt}' terdeteksi. Docker/Wings biasanya tidak dapat berjalan di sini."
                ;;
            *)
                note "Virtualisasi: ${virt}"
                ;;
        esac
    fi
}

check_existing() {
    if [ -f "${PANEL_DIR}/artisan" ]; then
        PREEXISTING_PANEL=true
    fi
    if [ -x "$WINGS_BIN" ] || [ -f "${WINGS_DIR}/config.yml" ]; then
        PREEXISTING_WINGS=true
    fi

    if [ "$PREEXISTING_PANEL" = true ] && [ "$INSTALL_PANEL" = true ]; then
        warn "Panel sudah terpasang di ${PANEL_DIR}."
        local lanjut
        lanjut=$(ask_yesno "Perbarui/timpa instalasi yang ada?" n)
        [ "$lanjut" = y ] || die "Instalasi dibatalkan oleh pengguna."
    fi
    if [ "$PREEXISTING_WINGS" = true ] && [ "$INSTALL_WINGS" = true ]; then
        warn "Wings sudah terpasang di mesin ini."
        local lanjut
        lanjut=$(ask_yesno "Perbarui instalasi Wings yang ada?" n)
        [ "$lanjut" = y ] || die "Instalasi dibatalkan oleh pengguna."
    fi
}

verify_dns() {
    local fqdn="$1"
    if is_ip "$fqdn"; then
        return 0
    fi
    if [ "$DRY_RUN" -eq 1 ]; then
        note "[dry-run] Verifikasi DNS untuk ${fqdn}"
        return 0
    fi

    case "$PKG" in
        apt) pkg_install "dnsutils" ;;
        dnf) pkg_install "bind-utils" ;;
    esac

    local server_ip record
    server_ip=$(curl -4 -fsS --connect-timeout 10 https://checkip.pterodactyl-installer.se 2>/dev/null || true)
    record=""
    if need_cmd dig; then
        record=$(dig +short @"${DNS_RESOLVER:-8.8.8.8}" "$fqdn" A 2>/dev/null | tail -n1 || true)
    elif need_cmd host; then
        record=$(host -t A "$fqdn" 2>/dev/null | awk '/has address/ {print $NF; exit}' || true)
    fi

    if [ -z "$record" ]; then
        warn "Belum ada record A untuk ${fqdn}."
    elif [ -n "$server_ip" ] && [ "$record" != "$server_ip" ]; then
        warn "DNS ${fqdn} → ${record}, sedangkan IP server ${server_ip}."
        warn "Jika memakai Cloudflare, matikan proxy (awan oranye) agar Certbot berhasil."
    else
        ok "DNS ${fqdn} → ${record} cocok dengan IP server"
        return 0
    fi

    local lanjut
    lanjut=$(ask_yesno "Lanjutkan meski DNS belum siap?" n)
    [ "$lanjut" = y ] || die "Dibatalkan karena DNS belum siap."
}

# ============================================================================
#  PAKET & REPOSITORI
# ============================================================================

pkg_update() {
    case "$PKG" in
        apt) DEBIAN_FRONTEND=noninteractive apt-get update -y ;;
        dnf) dnf -y makecache -q ;;
    esac
}

pkg_install() {
    local packages="$1"
    # shellcheck disable=SC2086
    case "$PKG" in
        apt) DEBIAN_FRONTEND=noninteractive apt-get install -y -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold $packages ;;
        dnf) dnf install -y $packages ;;
    esac
}

svc_enable_now() {
    local svc="$1"
    systemctl enable "$svc" >/dev/null 2>&1 || true
    systemctl restart "$svc" >/dev/null 2>&1 || systemctl start "$svc" >/dev/null 2>&1 || true
}

add_php_repo() {
    case "$OS_ID" in
        ubuntu)
            pkg_install "software-properties-common ca-certificates curl gnupg lsb-release"
            add-apt-repository -y universe >/dev/null 2>&1 || true
            LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php >/dev/null 2>&1
            ;;
        debian)
            pkg_install "ca-certificates curl gnupg lsb-release apt-transport-https"
            install -d -m 0755 /etc/apt/keyrings
            curl -fsSL https://packages.sury.org/php/apt.gpg -o /etc/apt/keyrings/sury-php.gpg
            printf 'deb [signed-by=/etc/apt/keyrings/sury-php.gpg] https://packages.sury.org/php/ %s main\n' "$(lsb_release -cs)" \
                >/etc/apt/sources.list.d/sury-php.list
            ;;
        rocky|almalinux)
            pkg_install "epel-release"
            local remi_rpm="https://rpms.remirepo.net/enterprise/remi-release-${OS_VER_MAJOR}.rpm"
            pkg_install "$remi_rpm" || true
            dnf module reset -y php >/dev/null 2>&1 || true
            dnf module enable -y "php:remi-${PHP_VERSION}" >/dev/null 2>&1 || true
            ;;
    esac
}

add_mariadb_repo() {
    local tmp
    tmp=$(mktemp)
    if download "$MARIADB_REPO_SETUP" "$tmp" 2>/dev/null; then
        bash "$tmp" --mariadb-server-version="mariadb-11.4" --skip-maxscale --skip-tools >/dev/null 2>&1 || true
    fi
    rm -f "$tmp"
}

add_docker_repo() {
    case "$OS_ID" in
        ubuntu|debian)
            pkg_install "ca-certificates curl gnupg"
            install -d -m 0755 /etc/apt/keyrings
            curl -fsSL "https://download.docker.com/linux/${OS_ID}/gpg" -o /etc/apt/keyrings/docker.asc
            chmod a+r /etc/apt/keyrings/docker.asc
            printf 'deb [arch=%s signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/%s %s stable\n' \
                "$(dpkg --print-architecture)" "$OS_ID" "$(lsb_release -cs)" \
                >/etc/apt/sources.list.d/docker.list
            ;;
        rocky|almalinux)
            pkg_install "dnf-plugins-core"
            dnf config-manager --add-repo "https://download.docker.com/linux/centos/docker-ce.repo" >/dev/null 2>&1 || true
            ;;
    esac
}

add_node_repo() {
    case "$OS_ID" in
        ubuntu|debian)
            install -d -m 0755 /etc/apt/keyrings
            curl -fsSL "https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key" -o /etc/apt/keyrings/nodesource.gpg
            printf 'deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_%s.x nodistro main\n' "$NODE_MAJOR" \
                >/etc/apt/sources.list.d/nodesource.list
            ;;
        rocky|almalinux)
            curl -fsSL "https://rpm.nodesource.com/setup_${NODE_MAJOR}.x" -o /tmp/nodesource.sh
            bash /tmp/nodesource.sh >/dev/null 2>&1 || true
            rm -f /tmp/nodesource.sh
            ;;
    esac
}

install_firewall() {
    case "$FIREWALL_KIND" in
        ufw)
            need_cmd ufw || { pkg_update; pkg_install "ufw"; }
            ufw --force enable >/dev/null 2>&1
            ;;
        firewalld)
            need_cmd firewall-cmd || { pkg_update; pkg_install "firewalld"; }
            svc_enable_now firewalld
            ;;
    esac
}

allow_ports() {
    local ports="$1" port
    for port in $ports; do
        case "$FIREWALL_KIND" in
            ufw) ufw allow "${port}/tcp" >/dev/null 2>&1 || true ;;
            firewalld) firewall-cmd --zone=public --add-port="${port}/tcp" --permanent >/dev/null 2>&1 || true ;;
        esac
    done
    case "$FIREWALL_KIND" in
        ufw) ufw --force reload >/dev/null 2>&1 || true ;;
        firewalld) firewall-cmd --reload >/dev/null 2>&1 || true ;;
    esac
}

# ============================================================================
#  DATABASE
# ============================================================================

db_root_run() {  # db_root_run "<sql>"
    mariadb -u root --protocol=socket -e "$1" 2>/dev/null || mysql -u root --protocol=socket -e "$1"
}

db_create_user() {
    local user="$1" pass="$2" host="${3:-$DB_HOST_LOCAL}"
    db_root_run "CREATE USER IF NOT EXISTS '${user}'@'${host}' IDENTIFIED BY '${pass}';"
    db_root_run "ALTER USER '${user}'@'${host}' IDENTIFIED BY '${pass}';"
}
db_grant() {
    local db="$1" user="$2" host="${3:-$DB_HOST_LOCAL}"
    if [ "$db" = "*" ]; then
        db_root_run "GRANT ALL PRIVILEGES ON *.* TO '${user}'@'${host}' WITH GRANT OPTION;"
    else
        db_root_run "GRANT ALL PRIVILEGES ON \`${db}\`.* TO '${user}'@'${host}' WITH GRANT OPTION;"
    fi
    db_root_run "FLUSH PRIVILEGES;"
}
db_create() {
    local db="$1" user="$2" host="${3:-$DB_HOST_LOCAL}"
    db_root_run "CREATE DATABASE IF NOT EXISTS \`${db}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    db_grant "$db" "$user" "$host"
}

# ============================================================================
#  PANEL
# ============================================================================

panel_dependencies() {
    case "$PKG" in
        apt)
            add_php_repo
            pkg_update
            add_mariadb_repo
            pkg_update
            pkg_install "php${PHP_VERSION}-cli php${PHP_VERSION}-common php${PHP_VERSION}-fpm php${PHP_VERSION}-gd \
                php${PHP_VERSION}-mysql php${PHP_VERSION}-mbstring php${PHP_VERSION}-bcmath php${PHP_VERSION}-xml \
                php${PHP_VERSION}-curl php${PHP_VERSION}-zip php${PHP_VERSION}-intl php${PHP_VERSION}-sqlite3 \
                mariadb-server mariadb-client nginx redis-server zip unzip tar git cron ca-certificates"
            ;;
        dnf)
            add_php_repo
            add_mariadb_repo
            pkg_update
            pkg_install "php php-cli php-fpm php-common php-gd php-mysqlnd php-mbstring php-bcmath php-xml \
                php-curl php-zip php-intl php-pdo php-opcache php-posix \
                mariadb-server nginx redis zip unzip tar git cronie policycoreutils-python-utils"
            setsebool -P httpd_can_network_connect 1 2>/dev/null || true
            setsebool -P httpd_execmem 1 2>/dev/null || true
            setsebool -P httpd_unified 1 2>/dev/null || true
            ;;
    esac

    if [ "$OPT_WITH_NODE" -eq 1 ]; then
        add_node_repo
        pkg_update
        pkg_install "nodejs"
        ok "Node.js $(node -v 2>/dev/null) terpasang"
    fi
}

panel_php_tuning() {
    local ini="/etc/php/${PHP_VERSION}/fpm/conf.d/99-arkanprojects.ini"
    [ -d "/etc/php/${PHP_VERSION}/fpm/conf.d" ] || ini="/etc/php.d/99-arkanprojects.ini"

    if [ "$PKG" = "dnf" ]; then
        cat >"$PHP_INI_DIR/pterodactyl.conf" <<POOL_EOF
[www]
user = ${WEB_USER}
group = ${WEB_GROUP}
listen = ${PHP_SOCK}
listen.owner = ${WEB_USER}
listen.group = ${WEB_GROUP}
listen.mode = 0660
pm = dynamic
pm.max_children = 24
pm.start_servers = 4
pm.min_spare_servers = 2
pm.max_spare_servers = 6
pm.max_requests = 500
php_admin_value[upload_max_filesize] = 100M
php_admin_value[post_max_size] = 100M
php_admin_value[memory_limit] = 256M
POOL_EOF
    fi

    cat >"$ini" <<INI_EOF
; Pengaturan PHP untuk Pterodactyl Panel (dibuat oleh ArkanProjects)
upload_max_filesize = 100M
post_max_size = 100M
memory_limit = 256M
max_execution_time = 120
opcache.enable = 1
opcache.validate_timestamps = 0
opcache.memory_consumption = 128
opcache.max_accelerated_files = 10000
INI_EOF

    systemctl enable nginx mariadb "$PHP_SERVICE" "$REDIS_SERVICE" >/dev/null 2>&1 || true
    systemctl restart nginx >/dev/null 2>&1 || true
    svc_enable_now "$PHP_SERVICE"
    svc_enable_now "$MARIADB_SERVICE"
    svc_enable_now "$REDIS_SERVICE"

    local composer_tmp="/tmp/composer-setup.php"
    curl -fsSL https://getcomposer.org/installer -o "$composer_tmp"
    php "$composer_tmp" --install-dir=/usr/local/bin --filename=composer >/dev/null
    rm -f "$composer_tmp"
    export PATH="/usr/local/bin:${PATH}"

    if [ "$PKG" = "dnf" ]; then
        systemctl enable php-fpm >/dev/null 2>&1 || true
    fi
}

panel_fetch_files() {
    mkdir -p "$PANEL_DIR"
    cd "$PANEL_DIR"

    if [ "$PREEXISTING_PANEL" = true ]; then
        backup_panel "pra-update" || true
    fi

    local tarball="/tmp/panel.tar.gz"
    download "$PANEL_DL_URL" "$tarball"
    tar -xzf "$tarball" -C "$PANEL_DIR"
    rm -f "$tarball"

    chmod -R 755 storage/* bootstrap/cache/ 2>/dev/null || true
    [ -f .env ] || cp .env.example .env

    COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev --optimize-autoloader --no-interaction --no-progress
}

panel_configure_env() {
    cd "$PANEL_DIR"

    local app_url
    if [ "$CONFIGURE_LETSENCRYPT" = true ] || [ "${OPT_ASSUME_SSL:-}" = "ya" ]; then
        app_url="https://${OPT_FQDN}"
    else
        app_url="http://${OPT_FQDN}"
    fi

    php artisan key:generate --force >/dev/null 2>&1 || php artisan key:generate --force

    php artisan p:environment:setup \
        --author="$OPT_EMAIL" \
        --url="$app_url" \
        --timezone="$OPT_TIMEZONE" \
        --cache=redis --session=redis --queue=redis \
        --redis-host=127.0.0.1 --redis-port=6379 --redis-pass="null" \
        --settings-ui=true --no-interaction >/dev/null

    php artisan p:environment:database \
        --host=127.0.0.1 --port=3306 \
        --database="$OPT_DB_NAME" --username="$OPT_DB_USER" --password="$OPT_DB_PASS" >/dev/null

    php artisan migrate --seed --force >/dev/null
    php artisan p:user:make \
        --email="$OPT_ADMIN_EMAIL" --username="$OPT_ADMIN_USER" \
        --name-first="$OPT_ADMIN_FIRST" --name-last="$OPT_ADMIN_LAST" \
        --password="$OPT_ADMIN_PASS" --admin=1 >/dev/null
}

panel_nginx() {
    # Config langsung ditulis agar tidak bergantung pada repo contoh
    local config_dir conf
    if [ "$PKG" = "apt" ]; then
        config_dir="/etc/nginx/sites-available"
        conf="${config_dir}/pterodactyl.conf"
        rm -f /etc/nginx/sites-enabled/default
    else
        config_dir="/etc/nginx/conf.d"
        conf="${config_dir}/pterodactyl.conf"
    fi

    local listen_block redirect_block
    if [ "$CONFIGURE_LETSENCRYPT" = true ]; then
        # Certbot yang akan menambahkan blok 443; sediakan server blok awal
        listen_block="listen 80;"
        redirect_block=""
    elif [ "${OPT_ASSUME_SSL:-}" = "ya" ]; then
        listen_block="listen 80;"
        redirect_block="return 301 https://\$host\$request_uri;"
    else
        listen_block="listen 80;"
        redirect_block=""
    fi

    cat >"$conf" <<NGINX_EOF
server {
    ${listen_block}
    server_name ${OPT_FQDN};
    ${redirect_block}

    root ${PANEL_DIR}/public;
    index index.php index.html;

    charset utf-8;
    client_max_body_size 100m;
    client_body_timeout 120s;

    add_header X-Content-Type-Options "nosniff" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;

    access_log off;
    error_log /var/log/nginx/pterodactyl.error.log error;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:${PHP_SOCK};
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param PHP_VALUE "upload_max_filesize = 100M \n post_max_size=100M \n memory_limit=256M";
        fastcgi_intercept_errors off;
        fastcgi_buffer_size 16k;
        fastcgi_buffers 4 16k;
        fastcgi_connect_timeout 300;
        fastcgi_send_timeout 300;
        fastcgi_read_timeout 300;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
NGINX_EOF

    if [ "$PKG" = "apt" ]; then
        ln -sf "$conf" /etc/nginx/sites-enabled/pterodactyl.conf
    fi

    nginx -t >/dev/null 2>&1 || die "Konfigurasi Nginx tidak valid. Periksa /etc/nginx."
    systemctl restart nginx
}

panel_permissions() {
    chown -R "${WEB_USER}:${WEB_GROUP}" "$PANEL_DIR"
    chmod -R 755 "$PANEL_DIR/storage" "$PANEL_DIR/bootstrap/cache" 2>/dev/null || true

    # Queue worker
    local unit_after="redis-server.service"
    [ "$PKG" = "dnf" ] && unit_after="redis.service"
    cat >/etc/systemd/system/pteroq.service <<QUEUE_EOF
[Unit]
Description=Pterodactyl Queue Worker
After=${unit_after} mariadb.service

[Service]
User=${WEB_USER}
Group=${WEB_GROUP}
Restart=always
RestartSec=5s
ExecStart=/usr/bin/php ${PANEL_DIR}/artisan queue:work --queue=high,standard,low --sleep=3 --tries=3
StartLimitInterval=180
StartLimitBurst=30

[Install]
WantedBy=multi-user.target
QUEUE_EOF

    systemctl daemon-reload
    svc_enable_now pteroq.service

    # Cron scheduler
    local cron_line="* * * * * php ${PANEL_DIR}/artisan schedule:run >> /dev/null 2>&1"
    (crontab -l 2>/dev/null | grep -v 'artisan schedule:run' || true; printf '%s\n' "$cron_line") | crontab -
}

panel_ssl() {
    [ "$CONFIGURE_LETSENCRYPT" = true ] || { note "SSL dilewati (dinonaktifkan oleh pengguna)."; return 0; }

    if is_ip "$OPT_FQDN"; then
        warn "Let's Encrypt tidak dapat diterbitkan untuk alamat IP — SSL dilewati."
        return 0
    fi

    case "$PKG" in
        apt) pkg_install "certbot python3-certbot-nginx" ;;
        dnf) pkg_install "certbot python3-certbot-nginx" ;;
    esac

    if certbot --nginx --non-interactive --agree-tos --redirect --no-eff-email \
        -m "$OPT_EMAIL" -d "$OPT_FQDN" >/dev/null 2>&1; then
        ok "Sertifikat Let's Encrypt aktif untuk ${OPT_FQDN}"

        # Perkuat konfigurasi TLS yang dihasilkan Certbot
        local ssl_conf="/etc/letsencrypt/options-ssl-nginx.conf"
        if [ -f "$ssl_conf" ] && ! grep -q 'ssl_protocols' "$ssl_conf"; then
            {
                printf 'ssl_session_cache shared:le_nginx_SSL:10m;\n'
                printf 'ssl_session_timeout 1440m;\n'
                printf 'ssl_protocols TLSv1.2 TLSv1.3;\n'
                printf 'ssl_prefer_server_ciphers off;\n'
                printf 'ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384;\n'
            } >>"$ssl_conf"
        fi
        # Tambahkan HSTS pada blok HTTPS yang dihasilkan Certbot
        local conf
        if [ "$PKG" = "apt" ]; then conf="/etc/nginx/sites-available/pterodactyl.conf"; else conf="/etc/nginx/conf.d/pterodactyl.conf"; fi
        if [ -f "$conf" ] && ! grep -q 'Strict-Transport-Security' "$conf"; then
            sed -i '0,/ssl_certificate /s//add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;\n\n    ssl_certificate /' "$conf" || true
        fi
        systemctl reload nginx >/dev/null 2>&1 || true
    else
        warn "Penerbitan sertifikat gagal. Periksa DNS/proxy, lalu jalankan: certbot --nginx -d ${OPT_FQDN}"
    fi
}

# ============================================================================
#  BACKUP & RESTORE
# ============================================================================

backup_panel() {
    local tag="${1:-manual}"
    install -d -m 0750 "$ARKAN_BACKUP_DIR"
    local stamp target
    stamp=$(date '+%Y%m%d-%H%M%S')
    target="${ARKAN_BACKUP_DIR}/panel-${tag}-${stamp}.tar.gz"

    if [ -f "${PANEL_DIR}/.env" ]; then
        local dump="/tmp/arkan-db-${stamp}.sql"
        mysqldump --single-transaction --quick --lock-tables=false \
            -u root panel >"$dump" 2>/dev/null || mariadb-dump -u root panel >"$dump" 2>/dev/null || true
        tar -czf "$target" -C "$PANEL_DIR" --exclude=node_modules . 2>/dev/null || true
        if [ -s "$dump" ]; then
            gzip -c "$dump" >"${target%.tar.gz}-db.sql.gz"
        fi
        rm -f "$dump"
    fi

    if [ -f "$target" ]; then
        ln -sfn "$target" "${ARKAN_BACKUP_DIR}/latest-panel.tar.gz"
        ok "Backup panel: $target"
    fi
}

# ============================================================================
#  WINGS
# ============================================================================

wings_dependencies() {
    case "$PKG" in
        apt)
            add_docker_repo
            pkg_update
            pkg_install "docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin"
            if [ "$CONFIGURE_LETSENCRYPT" = true ]; then pkg_install "certbot"; fi
            if [ "${INSTALL_MARIADB_WINGS:-0}" = "1" ]; then pkg_install "mariadb-server"; fi
            ;;
        dnf)
            add_docker_repo
            pkg_update
            pkg_install "docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin"
            if [ "$CONFIGURE_LETSENCRYPT" = true ]; then pkg_install "certbot"; fi
            if [ "${INSTALL_MARIADB_WINGS:-0}" = "1" ]; then pkg_install "mariadb-server"; fi
            ;;
    esac

    svc_enable_now docker
    mkdir -p /var/lib/wings /var/log/wings
}

wings_install_binary() {
    mkdir -p "$WINGS_DIR"
    local tmp="/tmp/wings-${ARCH}"
    download "${WINGS_DL_BASE}${ARCH}" "$tmp"
    install -m 0755 "$tmp" "$WINGS_BIN"
    rm -f "$tmp"
}

wings_service() {
    cat >/etc/systemd/system/wings.service <<'WINGS_UNIT_EOF'
[Unit]
Description=Pterodactyl Wings Daemon
After=docker.service
Requires=docker.service
PartOf=docker.service

[Service]
User=root
WorkingDirectory=/etc/pterodactyl
LimitNOFILE=4096
PIDFile=/var/run/wings/daemon.pid
ExecStart=/usr/local/bin/wings
Restart=on-failure
StartLimitInterval=180
StartLimitBurst=30
RestartSec=5s

[Install]
WantedBy=multi-user.target
WINGS_UNIT_EOF

    systemctl daemon-reload
    systemctl enable wings >/dev/null 2>&1 || true

    if [ -f "${WINGS_DIR}/config.yml" ]; then
        svc_enable_now wings
        note "config.yml ditemukan — daemon Wings dijalankan."
    else
        note "config.yml belum ada: buat node di Panel lalu simpan konfigurasinya,"
        note "kemudian jalankan: systemctl start wings"
    fi
}

wings_dbhost() {
    if [ "$CONFIGURE_DBHOST" != true ]; then
        note "Database host untuk node dilewati."
        return 0
    fi

    [ "$OPT_DBHOST_HOST" = "127.0.0.1" ] || OPT_DBHOST_HOST="%"
    db_create_user "$OPT_DBHOST_USER" "$OPT_DBHOST_PASS" "$OPT_DBHOST_HOST"
    db_grant "*" "$OPT_DBHOST_USER" "$OPT_DBHOST_HOST"

    if [ "$OPT_DBHOST_HOST" = "%" ]; then
        note "Mengizinkan koneksi database dari alamat lain (bind 0.0.0.0)."
        case "$PKG" in
            apt)
                local cnf
                for cnf in /etc/mysql/mariadb.conf.d/50-server.cnf /etc/mysql/mysql.conf.d/mysqld.cnf; do
                    [ -f "$cnf" ] && sed -i 's/^bind-address.*/bind-address = 0.0.0.0/' "$cnf"
                done
                ;;
            dnf)
                sed -i 's/^#\?bind-address.*/bind-address = 0.0.0.0/' /etc/my.cnf.d/mariadb-server.cnf 2>/dev/null || true
                ;;
        esac
        [ "$CONFIGURE_DB_FIREWALL" = true ] && allow_ports "3306"
        systemctl restart "$MARIADB_SERVICE" >/dev/null 2>&1 || true
    fi

    ok "User database host '${OPT_DBHOST_USER}' siap"
}

wings_ssl() {
    [ "$CONFIGURE_LETSENCRYPT" = true ] || return 0
    is_ip "$OPT_FQDN" && { warn "Wings SSL memerlukan domain, bukan IP — dilewati."; return 0; }

    local was_running=false
    systemctl is-active --quiet nginx && was_running=true
    $was_running && systemctl stop nginx

    if certbot certonly --standalone --non-interactive --agree-tos --no-eff-email \
        -m "${OPT_EMAIL}" -d "$OPT_FQDN" >/dev/null 2>&1; then
        ok "Sertifikat Wings aktif untuk ${OPT_FQDN}"
    else
        warn "Sertifikat Wings gagal diterbitkan."
    fi
    $was_running && systemctl start nginx
}

# ============================================================================
#  KONFIGURASI TAMBAHAN
# ============================================================================

setup_logrotate() {
    cat >"$ARKAN_LOGROTATE" <<'LOGROTATE_EOF'
/var/log/arkanprojects-installer.log {
    weekly
    rotate 8
    compress
    delaycompress
    missingok
    notifempty
    copytruncate
}
LOGROTATE_EOF

    cat >/etc/logrotate.d/pterodactyl <<'LOGROTATE_PANEL_EOF'
/var/www/pterodactyl/storage/logs/*.log {
    weekly
    rotate 6
    compress
    delaycompress
    missingok
    notifempty
    copytruncate
}
LOGROTATE_PANEL_EOF
}

write_runtime_config() {
    install -d -m 0750 "$ARKAN_HOME"
    {
        printf 'ARKAN_VERSION=%q\n' "$ARKAN_VERSION"
        printf 'OS_ID=%q\n' "$OS_ID"
        printf 'PKG=%q\n' "$PKG"
        printf 'PANEL_DIR=%q\n' "$PANEL_DIR"
        printf 'WINGS_DIR=%q\n' "$WINGS_DIR"
        printf 'WEB_USER=%q\n' "$WEB_USER"
        printf 'PHP_SERVICE=%q\n' "$PHP_SERVICE"
        printf 'PHP_SOCK=%q\n' "$PHP_SOCK"
        printf 'MARIADB_SERVICE=%q\n' "$MARIADB_SERVICE"
        printf 'REDIS_SERVICE=%q\n' "$REDIS_SERVICE"
        printf 'FIREWALL_KIND=%q\n' "$FIREWALL_KIND"
        printf 'FQDN=%q\n' "${OPT_FQDN:-}"
        printf 'DB_NAME=%q\n' "${OPT_DB_NAME:-}"
        printf 'DB_USER=%q\n' "${OPT_DB_USER:-}"
        printf 'DB_PASS=%q\n' "${OPT_DB_PASS:-}"
        printf 'ADMIN_EMAIL=%q\n' "${OPT_ADMIN_EMAIL:-}"
        printf 'INSTALLED_PANEL=%q\n' "$INSTALL_PANEL"
        printf 'INSTALLED_WINGS=%q\n' "$INSTALL_WINGS"
        printf 'SSL=%q\n' "$CONFIGURE_LETSENCRYPT"
        printf 'INSTALLED_AT=%q\n' "$(date '+%Y-%m-%d %H:%M:%S')"
    } >"$ARKAN_CONF"
    chmod 600 "$ARKAN_CONF"
}

# ============================================================================
#  CLI "arkan" — dipasang ke /usr/local/bin/arkan
# ============================================================================

install_arkan_cli() {
    cat >"$ARKAN_BIN" <<'ARKAN_CLI_EOF'
#!/usr/bin/env bash
# arkan — CLI manajemen Pterodactyl (dibuat oleh ArkanProjects Installer)
set -uo pipefail

CONF="/etc/arkanprojects/arkan.conf"
if [ ! -r "$CONF" ]; then
    printf 'arkan: konfigurasi %s tidak ditemukan. Jalankan installer ArkanProjects dulu.\n' "$CONF" >&2
    exit 1
fi
# shellcheck disable=SC1090
. "$CONF"

BACKUP_DIR="/var/backups/arkanprojects"
BOLD=$'\033[1m'; DIM=$'\033[2m'; RED=$'\033[31m'; GREEN=$'\033[32m'
YELLOW=$'\033[33m'; CYAN=$'\033[38;2;34;211;238m'; VIOLET=$'\033[38;2;139;92;246m'; RESET=$'\033[0m'

[ -t 1 ] || { BOLD=""; DIM=""; RED=""; GREEN=""; YELLOW=""; CYAN=""; VIOLET=""; RESET=""; }

ok()   { printf '  %s %s\n' "${GREEN}✔${RESET}" "$*"; }
info() { printf '  %s %s\n' "${CYAN}•${RESET}" "$*"; }
warn() { printf '  %s %s\n' "${YELLOW}!${RESET}" "$*"; }
bad()  { printf '  %s %s\n' "${RED}✖${RESET}" "$*"; }
head() { printf '\n  %s%s%s\n  %s\n' "$BOLD$VIOLET" "$1" "$RESET" "${DIM}──────────────────────────────────────────${RESET}"; }
svc_state() { systemctl is-active "$1" 2>/dev/null || printf 'tidak aktif'; }
have() { command -v "$1" >/dev/null 2>&1; }
confirm() {
    local p="$1" a=""
    printf '  %s %s (y/N): ' "$(printf '%s' "›")" "$p"
    read -r a || true
    [[ "${a,,}" == y* ]]
}

usage() {
    cat <<USAGE
arkan — manajemen Pterodactyl (ArkanProjects ${ARKAN_VERSION})

  arkan status              Kesehatan service & versi
  arkan doctor              Diagnosa lengkap sistem
  arkan info                Ringkasan konfigurasi & kredensial
  arkan update panel        Backup lalu update Panel
  arkan update wings        Perbarui binary Wings
  arkan backup [--keep N]   Backup database + file panel
  arkan restore <file>      Pulihkan dari backup
  arkan logs <target>       panel | nginx | queue | wings | installer
  arkan restart <target>    panel | nginx | queue | redis | db | wings | all
  arkan ssl renew           Perpanjang sertifikat Let's Encrypt
  arkan uninstall           Hapus instalasi di mesin ini
  arkan version             Versi CLI & installer
USAGE
}

cmd_status() {
    head "Status Pterodactyl"
    local svc
    for svc in nginx mariadb "$PHP_SERVICE" "$REDIS_SERVICE"; do
        printf '  %-22s %s\n' "$svc" "$(svc_state "$svc")"
    done
    if [ "${INSTALLED_PANEL}" = "true" ]; then
        printf '  %-22s %s\n' "pteroq.service" "$(svc_state pteroq.service)"
        if [ -f "${PANEL_DIR}/config/app.php" ]; then
            info "Panel: $(cd "${PANEL_DIR}" && php artisan --version 2>/dev/null || printf 'tidak dikenal')"
        fi
        info "URL: $( [ "${SSL}" = "true" ] && printf 'https://%s' "${FQDN}" || printf 'http://%s' "${FQDN}" )"
    fi
    if [ "${INSTALLED_WINGS}" = "true" ]; then
        printf '  %-22s %s\n' "wings.service" "$(svc_state wings.service)"
    fi
    printf '\n'
}

cmd_doctor() {
    head "Diagnosa (arkan doctor)"
    local issue=0

    info "OS: $(. /etc/os-release 2>/dev/null; printf '%s' "${PRETTY_NAME:-unknown}")"
    info "Ruang disk /: $(df -Ph / | awk 'NR==2 {print $4" bebas ("$5" terpakai)"}')"

    local php_bin="php"
    if have "$php_bin"; then ok "PHP: $($php_bin -v 2>/dev/null | head -n1)"; else bad "PHP tidak ditemukan"; issue=$((issue+1)); fi

    if [ -S "$PHP_SOCK" ]; then ok "Socket PHP-FPM: ${PHP_SOCK}"; else bad "Socket PHP-FPM tidak ada: ${PHP_SOCK}"; issue=$((issue+1)); fi

    if nginx -t >/dev/null 2>&1; then ok "Konfigurasi Nginx valid"; else bad "Nginx menolak konfigurasi (nginx -t)"; issue=$((issue+1)); fi

    if [ -f "${PANEL_DIR}/.env" ]; then
        ok "Panel: ${PANEL_DIR}"
        if (cd "$PANEL_DIR" && php artisan migrate:status >/dev/null 2>&1); then
            ok "Koneksi database panel sehat"
        else
            bad "Panel tidak dapat terhubung ke database"; issue=$((issue+1))
        fi
        if [ -d "${PANEL_DIR}/vendor" ]; then ok "Dependensi Composer terpasang"; else bad "vendor/ belum ada (jalankan composer install)"; issue=$((issue+1)); fi
    else
        warn "Panel tidak terpasang di ${PANEL_DIR}"
    fi

    if have redis-cli; then
        if [ "$(redis-cli ping 2>/dev/null)" = "PONG" ]; then ok "Redis merespons PONG"; else bad "Redis tidak merespons"; issue=$((issue+1)); fi
    else
        warn "redis-cli tidak tersedia"
    fi

    if [ -f "/etc/systemd/system/pteroq.service" ]; then
        [ "$(svc_state pteroq.service)" = "active" ] && ok "Queue worker aktif" || { bad "Queue worker tidak aktif"; issue=$((issue+1)); }
    fi

    if crontab -l 2>/dev/null | grep -q 'artisan schedule:run'; then ok "Cron scheduler terpasang"; else warn "Cron scheduler belum terpasang"; fi

    if [ -n "${FQDN}" ] && ! [[ "${FQDN}" =~ ^[0-9.]+$ ]] && have getent; then
        local resolved
        resolved=$(getent hosts "$FQDN" 2>/dev/null | awk '{print $1; exit}')
        [ -n "$resolved" ] && ok "DNS ${FQDN} → ${resolved}" || warn "DNS ${FQDN} tidak dapat diresolusi dari server ini"
    fi

    if [ "${SSL}" = "true" ] && [ -d "/etc/letsencrypt/live/${FQDN}" ]; then
        local end
        end=$(openssl x509 -enddate -noout -in "/etc/letsencrypt/live/${FQDN}/fullchain.pem" 2>/dev/null | cut -d= -f2)
        if [ -n "$end" ]; then
            local days
            days=$(( ( $(date -d "$end" +%s 2>/dev/null || date -j -f '%b %d %T %Y %Z' "$end" +%s 2>/dev/null || printf '0') - $(date +%s) ) / 86400 ))
            if [ "$days" -gt 14 ] 2>/dev/null; then ok "Sertifikat SSL valid ${days} hari lagi"; else warn "Sertifikat SSL segera kedaluwarsa (${days} hari)"; fi
        fi
    fi

    if [ -f "${WINGS_DIR}/config.yml" ]; then
        ok "Wings config.yml tersedia"
        [ "$(svc_state wings.service)" = "active" ] && ok "Wings daemon aktif" || warn "Wings daemon belum berjalan"
    elif [ "${INSTALLED_WINGS}" = "true" ]; then
        warn "Wings terpasang tetapi config.yml belum ada (buat node di Panel)"
    fi

    printf '\n'
    if [ "$issue" -eq 0 ]; then ok "Tidak ada masalah kritis ditemukan."; else warn "${issue} hal perlu tindakan."; fi
    printf '\n'
    return 0
}

cmd_info() {
    head "Konfigurasi"
    printf '  %-18s %s\n' "Versi installer" "$ARKAN_VERSION"
    printf '  %-18s %s\n' "Distribusi" "${OS_ID}"
    printf '  %-18s %s\n' "FQDN" "${FQDN:-—}"
    printf '  %-18s %s\n' "Database" "${DB_NAME:-—}"
    printf '  %-18s %s\n' "DB user" "${DB_USER:-—}"
    printf '  %-18s %s\n' "DB password" "${DB_PASS:-—}"
    printf '  %-18s %s\n' "Admin" "${ADMIN_EMAIL:-—}"
    printf '  %-18s %s\n' "SSL" "${SSL:-false}"
    printf '  %-18s %s\n' "Dipasang" "${INSTALLED_AT:-—}"
    printf '\n'
}

cmd_backup() {
    local keep=5
    [ "${1:-}" = "--keep" ] && keep="${2:-5}"
    install -d -m 0750 "$BACKUP_DIR"
    local stamp target
    stamp=$(date '+%Y%m%d-%H%M%S')
    target="${BACKUP_DIR}/panel-manual-${stamp}.tar.gz"

    head "Backup"
    if [ "${DB_NAME:-}" = "" ]; then bad "Nama database tidak diketahui"; return 1; fi

    mysqldump --single-transaction --quick --lock-tables=false -u root "$DB_NAME" 2>/dev/null \
        | gzip >"${target%.tar.gz}-db.sql.gz" || { bad "Backup database gagal"; return 1; }
    ok "Database → ${target%.tar.gz}-db.sql.gz"

    tar -czf "$target" -C "$PANEL_DIR" --exclude=node_modules . 2>/dev/null && ok "File panel → $target" || warn "Backup file panel dilewati"

    ln -sfn "$target" "${BACKUP_DIR}/latest-panel.tar.gz"

    local old
    old=$(ls -1t "${BACKUP_DIR}"/panel-manual-*.tar.gz 2>/dev/null | tail -n "+$((keep + 1))" || true)
    if [ -n "$old" ]; then
        printf '%s\n' "$old" | while read -r f; do rm -f "$f" "${f%.tar.gz}-db.sql.gz"; done
        note_msg="Backup lama dibersihkan (menyimpan ${keep} terbaru)"
        info "$note_msg"
    fi
    printf '\n'
}

cmd_restore() {
    local archive="${1:-}"
    [ -z "$archive" ] && { bad "Sebutkan file backup: arkan restore /var/backups/arkanprojects/panel-xxx.tar.gz"; return 2; }
    [ -f "$archive" ] || { bad "File tidak ditemukan: $archive"; return 2; }
    confirm "Pulihkan panel dari ${archive}? Data saat ini akan ditimpa" || { warn "Dibatalkan."; return 0; }

    head "Restore"
    local dbdump="${archive%.tar.gz}-db.sql.gz"
    if [ -f "$dbdump" ]; then
        gunzip -c "$dbdump" | mariadb -u root "$DB_NAME" && ok "Database dipulihkan"
    fi

    cp -a "${PANEL_DIR}" "${PANEL_DIR}.before-restore-$(date +%s)" 2>/dev/null || true
    tar -xzf "$archive" -C "$PANEL_DIR" && ok "File panel dipulihkan"

    chown -R "${WEB_USER}:${WEB_USER}" "$PANEL_DIR" 2>/dev/null || true
    (cd "$PANEL_DIR" && php artisan optimize:clear >/dev/null 2>&1 || true)
    systemctl restart "$PHP_SERVICE" pteroq.service >/dev/null 2>&1 || true
    ok "Restore selesai"
    printf '\n'
}

cmd_update() {
    local target="${1:-}"
    case "$target" in
        panel)
            head "Update Panel"
            [ "${INSTALLED_PANEL}" = "true" ] || { bad "Panel tidak terpasang di mesin ini"; return 1; }
            cmd_backup --keep 5
            local tmp="/tmp/panel-update-$$.tar.gz"
            if ! curl -fsSL -o "$tmp" "https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz"; then
                bad "Gagal mengunduh rilis terbaru"; return 1
            fi
            tar -xzf "$tmp" -C "$PANEL_DIR" && rm -f "$tmp" && ok "Berkas panel diperbarui"
            (cd "$PANEL_DIR" && chmod -R 755 storage/* bootstrap/cache/ 2>/dev/null || true)
            (cd "$PANEL_DIR" && COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev --optimize-autoloader --no-interaction --no-progress) \
                && ok "Dependensi Composer diperbarui" || warn "Composer melaporkan masalah — periksa manual"
            (cd "$PANEL_DIR" && php artisan migrate --force && php artisan optimize:clear) \
                && ok "Migrasi & cache dibersihkan" || bad "Migrasi gagal — periksa log"
            systemctl restart pteroq.service >/dev/null 2>&1 || true
            ok "Update Panel selesai"
            ;;
        wings)
            head "Update Wings"
            local arch tmp
            arch=$(uname -m); [ "$arch" = "x86_64" ] && arch="amd64" || arch="arm64"
            tmp="/tmp/wings-${arch}"
            curl -fsSL -o "$tmp" "https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_${arch}" \
                || { bad "Gagal mengunduh Wings"; return 1; }
            systemctl stop wings 2>/dev/null || true
            install -m 0755 "$tmp" /usr/local/bin/wings
            rm -f "$tmp"
            [ -f "${WINGS_DIR}/config.yml" ] && systemctl start wings
            ok "Wings diperbarui"
            ;;
        *)
            bad "Target tidak dikenal: arkan update <panel|wings>"
            return 2
            ;;
    esac
    printf '\n'
}

cmd_logs() {
    case "${1:-}" in
        panel) (cd "$PANEL_DIR" && tail -f storage/logs/laravel.log) ;;
        nginx) tail -f /var/log/nginx/pterodactyl.error.log ;;
        queue) journalctl -u pteroq.service -f -n 100 ;;
        wings) journalctl -u wings.service -f -n 100 ;;
        installer) tail -f /var/log/arkanprojects-installer.log ;;
        *) bad "Gunakan: arkan logs <panel|nginx|queue|wings|installer>" ;;
    esac
}

cmd_restart() {
    case "${1:-}" in
        panel) systemctl restart "$PHP_SERVICE" && ok "PHP-FPM direstart" ;;
        nginx) systemctl restart nginx && ok "Nginx direstart" ;;
        queue) systemctl restart pteroq.service && ok "Queue worker direstart" ;;
        redis) systemctl restart "$REDIS_SERVICE" && ok "Redis direstart" ;;
        db) systemctl restart "$MARIADB_SERVICE" && ok "Database direstart" ;;
        wings) systemctl restart wings && ok "Wings direstart" ;;
        all)
            systemctl restart "$PHP_SERVICE" nginx "$REDIS_SERVICE" "$MARIADB_SERVICE" >/dev/null 2>&1 || true
            systemctl restart pteroq.service >/dev/null 2>&1 || true
            [ "${INSTALLED_WINGS}" = "true" ] && systemctl restart wings >/dev/null 2>&1 || true
            ok "Semua service direstart"
            ;;
        *) bad "Gunakan: arkan restart <panel|nginx|queue|redis|db|wings|all>" ;;
    esac
}

cmd_uninstall() {
    head "Uninstall ArkanProjects"
    warn "Ini akan menghentikan service dan menghapus file Pterodactyl."
    confirm "Lanjutkan uninstall?" || { warn "Dibatalkan."; return 0; }
    local keep_db="y"
    printf '  Simpan database? (Y/n): '; read -r keep_db || true
    [[ "${keep_db,,}" == n* ]] && DROP_DB=1 || DROP_DB=0

    systemctl disable --now pteroq.service wings 2>/dev/null || true
    rm -f /etc/systemd/system/pteroq.service /etc/systemd/system/wings.service /etc/systemd/system/multi-user.target.wants/wings.service
    systemctl daemon-reload
    rm -rf "$PANEL_DIR" "${WINGS_DIR}"

    if [ "$DROP_DB" = "1" ] && [ -n "${DB_NAME:-}" ]; then
        mariadb -u root -e "DROP DATABASE IF EXISTS \`${DB_NAME}\`;" 2>/dev/null || true
        ok "Database ${DB_NAME} dihapus"
    fi

    rm -f /etc/nginx/sites-enabled/pterodactyl.conf /etc/nginx/sites-available/pterodactyl.conf /etc/nginx/conf.d/pterodactyl.conf
    rm -f /etc/logrotate.d/arkanprojects /etc/logrotate.d/pterodactyl
    crontab -l 2>/dev/null | grep -v 'artisan schedule:run' | crontab - 2>/dev/null || true
    systemctl reload nginx 2>/dev/null || true

    ok "Pterodactyl dihapus. Backup tetap tersimpan di ${BACKUP_DIR}."
    printf '  %s\n' "Hapus CLI ini dengan: rm -f ${ARKAN_BIN} -r /etc/arkanprojects"
    printf '\n'
}

case "${1:-}" in
    status) shift; cmd_status ;;
    doctor) shift; cmd_doctor ;;
    info) shift; cmd_info ;;
    update) shift; cmd_update "${1:-}" ;;
    backup) shift; cmd_backup "$@" ;;
    restore) shift; cmd_restore "${1:-}" ;;
    logs) shift; cmd_logs "${1:-}" ;;
    restart) shift; cmd_restart "${1:-}" ;;
    ssl)
        shift
        case "${1:-renew}" in
            renew) certbot renew --quiet && ok "Sertifikat diperbarui" || warn "Tidak ada sertifikat yang perlu diperbarui" ;;
            *) bad "Gunakan: arkan ssl renew" ;;
        esac
        ;;
    uninstall) shift; cmd_uninstall ;;
    version|--version|-v) printf 'arkan (ArkanProjects) v%s\n' "$ARKAN_VERSION" ;;
    ""|-h|--help|help) usage ;;
    *) bad "Perintah tidak dikenal: $1"; printf '\n'; usage; exit 2 ;;
esac
ARKAN_CLI_EOF

    chmod 0755 "$ARKAN_BIN"
    ok "CLI terpasang: ${ARKAN_BIN} (coba: arkan status)"
}

# ============================================================================
#  INPUT INTERAKTIF
# ============================================================================

interactive_menu() {
    section "MODE INSTALASI"
    printf '  %s  %s\n' "$(c "$C_NEON_GREEN" '1')" "Panel saja"
    printf '  %s  %s\n' "$(c "$C_NEON_GREEN" '2')" "Wings saja (node untuk Panel yang sudah ada)"
    printf '  %s  %s\n' "$(c "$C_NEON_GREEN" '3')" "Panel + Wings (satu mesin)"
    gap

    local choice=""
    while [ -z "$choice" ]; do
        choice=$(ask "Pilih [1-3]" "3")
        case "$choice" in
            1) OPT_MODE="panel" ;;
            2) OPT_MODE="wings" ;;
            3) OPT_MODE="both" ;;
            *) warn "Masukkan 1, 2, atau 3."; choice="" ;;
        esac
    done
}

collect_shared_options() {
    # Firewall
    if [ -z "$OPT_FIREWALL" ]; then
        local label="Konfigurasi $([ "$FIREWALL_KIND" = ufw ] && printf 'UFW' || printf 'FirewallD')"
        OPT_FIREWALL=$(ask_yesno "${label}?" y)
    fi
    if [ "$OPT_FIREWALL" = "ya" ]; then CONFIGURE_FIREWALL=true; fi

    # Database host (hanya relevan untuk Wings)
    if [ "$INSTALL_WINGS" = true ] && [ -z "$OPT_DBHOST" ]; then
        OPT_DBHOST=$(ask_yesno "Buat user database host untuk node?" n)
    fi
    if [ "$OPT_DBHOST" = "ya" ]; then CONFIGURE_DBHOST=true; fi
    return 0
}

collect_panel_settings() {
    section "KONFIGURASI PANEL"

    # Database
    OPT_DB_NAME="${OPT_DB_NAME:-$(ask 'Nama database' 'panel')}"
    while [[ "$OPT_DB_NAME" == *-* ]]; do
        warn "Nama database tidak boleh mengandung tanda hubung."
        OPT_DB_NAME=$(ask 'Nama database' 'panel')
    done

    OPT_DB_USER="${OPT_DB_USER:-$(ask 'User database' 'pterodactyl')}"
    while [[ "$OPT_DB_USER" == *-* ]]; do
        warn "User database tidak boleh mengandung tanda hubung."
        OPT_DB_USER=$(ask 'User database' 'pterodactyl')
    done

    if [ -z "$OPT_DB_PASS" ]; then
        local generated
        generated=$(gen_passwd 48)
        OPT_DB_PASS=$(ask_secret "Password database (kosongkan untuk acak)" "$generated")
    fi

    OPT_TIMEZONE="${OPT_TIMEZONE:-$(ask 'Zona waktu' 'Asia/Jakarta')}"

    # Email & admin
    while ! is_email "${OPT_EMAIL}"; do
        if [ "$ASSUME_YES" -eq 1 ]; then
            die "Email tidak valid atau belum diberikan. Gunakan --email admin@domain.com"
        fi
        OPT_EMAIL=$(ask 'Email untuk SSL & Panel' "${OPT_EMAIL}")
        is_email "$OPT_EMAIL" || warn "Format email tidak valid."
    done

    OPT_ADMIN_EMAIL="${OPT_ADMIN_EMAIL:-$OPT_EMAIL}"
    while ! is_email "$OPT_ADMIN_EMAIL"; do
        OPT_ADMIN_EMAIL=$(ask 'Email admin pertama' "$OPT_EMAIL")
    done
    OPT_ADMIN_USER="${OPT_ADMIN_USER:-$(ask 'Username admin' 'arkan')}"
    OPT_ADMIN_PASS="${OPT_ADMIN_PASS:-$(gen_passwd 20)}"
    OPT_ADMIN_FIRST="${OPT_ADMIN_FIRST:-$(ask 'Nama depan admin' 'Arkan')}"
    OPT_ADMIN_LAST="${OPT_ADMIN_LAST:-$(ask 'Nama belakang admin' 'Projects')}"

    # FQDN
    if [ -z "$OPT_FQDN" ]; then
        if [ "$ASSUME_YES" -eq 1 ]; then
            die "FQDN belum diberikan. Gunakan --fqdn panel.domain.com"
        fi
        OPT_FQDN=$(ask 'FQDN panel (contoh: panel.domain.com)' "")
    fi
    [ -n "$OPT_FQDN" ] || die "FQDN tidak boleh kosong."

    # SSL
    if is_ip "$OPT_FQDN"; then
        warn "FQDN berupa alamat IP — Let's Encrypt tidak tersedia."
        CONFIGURE_LETSENCRYPT=false
    elif [ -z "$OPT_SSL" ]; then
        local answer
        answer=$(ask_yesno "Terbitkan sertifikat Let's Encrypt untuk ${OPT_FQDN}?" y)
        [ "$answer" = y ] && CONFIGURE_LETSENCRYPT=true
    elif [ "$OPT_SSL" = "ya" ]; then
        CONFIGURE_LETSENCRYPT=true
    fi

    if [ "$CONFIGURE_LETSENCRYPT" = true ]; then
        verify_dns "$OPT_FQDN"
    fi
}

collect_wings_settings() {
    section "KONFIGURASI WINGS"
    note "Wings memerlukan Docker. Konfigurasi node dibuat di Panel (Admin → Nodes)."

    if [ -z "$OPT_FQDN" ] && [ "$CONFIGURE_LETSENCRYPT" = true ]; then
        if [ "$ASSUME_YES" -eq 1 ]; then
            die "SSL Wings memerlukan --fqdn node.domain.com"
        fi
        OPT_FQDN=$(ask 'FQDN node (untuk SSL Wings)' "")
    fi

    if [ -z "$OPT_SSL" ]; then
        if is_ip "${OPT_FQDN:-0.0.0.0}"; then
            warn "SSL Wings dilewati (FQDN berupa IP)."
        else
            local answer
            answer=$(ask_yesno "Terbitkan sertifikat Let's Encrypt untuk Wings?" n)
            [ "$answer" = y ] && CONFIGURE_LETSENCRYPT=true
        fi
    elif [ "$OPT_SSL" = "ya" ]; then
        CONFIGURE_LETSENCRYPT=true
    fi

    if [ "$CONFIGURE_LETSENCRYPT" = true ]; then
        [ -n "$OPT_EMAIL" ] || OPT_EMAIL=$(ask "Email untuk Let's Encrypt" "")
        is_email "$OPT_EMAIL" || die "Email tidak valid untuk Certbot."
    fi

    if [ "$CONFIGURE_DBHOST" = true ]; then
        OPT_DBHOST_USER="${OPT_DBHOST_USER:-$(ask 'User database host' 'pterodactyluser')}"
        OPT_DBHOST_PASS="${OPT_DBHOST_PASS:-$(gen_passwd 32)}"
        if [ -z "$OPT_DBHOST_HOST" ]; then
            local external
            external=$(ask_yesno "Izinkan akses dari Panel (alamat eksternal)?" y)
            if [ "$external" = y ]; then
                OPT_DBHOST_HOST="%"
                if [ "$CONFIGURE_FIREWALL" = true ]; then
                    warn "Port 3306 bersifat sensitif — hanya buka bila benar-benar perlu."
                    local buka
                    buka=$(ask_yesno "Buka port 3306 di firewall?" n)
                    [ "$buka" = y ] && CONFIGURE_DB_FIREWALL=true
                fi
            else
                OPT_DBHOST_HOST="127.0.0.1"
            fi
        fi
        [ -n "$OPT_DBHOST_HOST" ] || OPT_DBHOST_HOST="127.0.0.1"
    fi
}

# ============================================================================
#  RENCANA & RINGKASAN
# ============================================================================

print_plan() {
    section "RENCANA INSTALASI"
    printf '  %-20s %s\n' "Sistem" "$(c "$C_BOLD" "$OS_PRETTY") · ${ARCH}"
    local mode_label="Panel"
    if [ "$INSTALL_PANEL" = true ] && [ "$INSTALL_WINGS" = true ]; then
        mode_label="Panel + Wings"
    elif [ "$INSTALL_WINGS" = true ]; then
        mode_label="Wings"
    fi
    printf '  %-20s %s\n' "Mode" "$mode_label"
    printf '  %-20s %s\n' "Panel / Wings" "${PANEL_VERSION:-terbaru} / ${WINGS_VERSION:-terbaru}"

    if [ "$INSTALL_PANEL" = true ]; then
        gap
        printf '  %s\n' "$(c "1;${C_NEON_GREEN}" 'PANEL')"
        printf '  %-20s %s\n' "FQDN" "$OPT_FQDN"
        printf '  %-20s %s\n' "App URL" "$([ "$CONFIGURE_LETSENCRYPT" = true ] && printf 'https' || printf 'http')://${OPT_FQDN}"
        printf '  %-20s %s\n' "Database" "${OPT_DB_NAME} (user: ${OPT_DB_USER})"
        printf '  %-20s %s\n' "Zona waktu" "$OPT_TIMEZONE"
        printf '  %-20s %s\n' "Email panel" "$OPT_EMAIL"
        printf '  %-20s %s\n' "Admin" "${OPT_ADMIN_USER} <${OPT_ADMIN_EMAIL}>"
    fi

    if [ "$INSTALL_WINGS" = true ]; then
        gap
        printf '  %s\n' "$(c "1;${C_NEON_VIOLET}" 'WINGS')"
        printf '  %-20s %s\n' "Docker" "docker-ce (repo resmi)"
        printf '  %-20s %s\n' "User DB host" "$([ "$CONFIGURE_DBHOST" = true ] && printf '%s' "${OPT_DBHOST_USER}" || printf 'tidak dibuat')"
        printf '  %-20s %s\n' "FQDN SSL" "${OPT_FQDN:-—}"
    fi

    gap
    printf '  %-20s %s\n' "Firewall" "$([ "$CONFIGURE_FIREWALL" = true ] && printf 'ya (%s)' "$FIREWALL_KIND" || printf 'tidak')"
    printf '  %-20s %s\n' "Let's Encrypt" "$([ "$CONFIGURE_LETSENCRYPT" = true ] && printf 'ya' || printf 'tidak')"
    printf '  %-20s %s\n' "Node.js opsional" "$([ "$OPT_WITH_NODE" -eq 1 ] && printf 'ya' || printf 'tidak')"
    gap
}

print_completion() {
    local took=$((SECONDS - INSTALL_START))

    gap
    printf '  %s\n' "$(c "1;${C_NEON_GREEN}" '✔ INSTALASI SELESAI')"
    hr
    gap

    if [ "$INSTALL_PANEL" = true ]; then
        local url="http://${OPT_FQDN}"
        [ "$CONFIGURE_LETSENCRYPT" = true ] && url="https://${OPT_FQDN}"
        printf '  %s %s\n' "$(c "$C_WHITE" 'Panel')" "$(c "1;${C_NEON_CYAN}" "$url")"
        printf '  %s %s\n' "$(c "$C_DIM" 'Admin   ')" "${OPT_ADMIN_USER}"
        printf '  %s %s\n' "$(c "$C_DIM" 'Password')" "$(c "$C_BOLD" "${OPT_ADMIN_PASS}")"
        printf '  %s %s\n' "$(c "$C_DIM" 'Email   ')" "${OPT_ADMIN_EMAIL}"
        gap
        note "Kredensial juga tersimpan di ${ARKAN_CONF} (mode 600)."
    fi

    if [ "$INSTALL_WINGS" = true ]; then
        gap
        printf '  %s\n' "$(c "1;${C_NEON_VIOLET}" 'Langkah Wings selanjutnya')"
        printf '  1. Buat node di Panel → Admin → Nodes\n'
        printf '  2. Salin konfigurasi (tab Configuration) ke %s\n' "$(c "$C_NEON_CYAN" "${WINGS_DIR}/config.yml")"
        printf '  3. Jalankan %s\n' "$(c "$C_NEON_CYAN" 'systemctl start wings')"
        printf '  4. Periksa dengan %s\n' "$(c "$C_NEON_CYAN" 'arkan status')"
    fi

    gap
    printf '  %s\n' "$(c "$C_DIM" "Durasi: $(elapsed_human "$took") · Log: ${LOG_FILE}")"
    printf '  %s\n' "$(c "$C_DIM" "Bantuan: arkan status · arkan doctor · arkan backup")"
    printf '  %s\n' "$(c "$C_DIM" "${ARKAN_REPO}")"
    gap
}

# ============================================================================
#  ALUR UTAMA
# ============================================================================

init_log() {
    mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null || true
    if ! { : >"$LOG_FILE"; } 2>/dev/null; then
        LOG_FILE="/tmp/arkanprojects-installer.log"
        { : >"$LOG_FILE"; } 2>/dev/null || true
    fi
    log "ArkanProjects Installer v${ARKAN_VERSION} dimulai (${*:-tanpa argumen})"
}

run_phase() {  # run_phase <label> <fungsi>
    local label="$1" fn="$2"
    step "$label"
    if [ "$DRY_RUN" -eq 1 ]; then
        note "[dry-run] ${label}"
        return 0
    fi
    "$fn"
}

firewall_phase() {
    [ "$CONFIGURE_FIREWALL" = true ] || { note "Firewall tidak diubah."; return 0; }
    install_firewall
    local ports="22 80 443"
    if [ "$INSTALL_WINGS" = true ]; then
        ports="22 80 443 8080 2022"
        [ "$CONFIGURE_DB_FIREWALL" = true ] && ports="${ports} 3306"
    fi
    allow_ports "$ports"
    ok "Firewall aktif — port dibuka: ${ports}"
}

install_panel_flow() {
    run_phase "Dependensi sistem & repositori" panel_dependencies
    run_phase "Tuning PHP-FPM & Composer" panel_php_tuning
    run_phase "Mengunduh berkas Panel" panel_fetch_files
    run_phase "Database & environment Panel" panel_database_flow
    run_phase "Konfigurasi Nginx" panel_nginx
    run_phase "Izin akses, queue worker & cron" panel_permissions
    run_phase "Sertifikat SSL" panel_ssl
}

panel_database_flow() {
    svc_enable_now "$MARIADB_SERVICE"
    db_create "$OPT_DB_NAME" "$OPT_DB_USER" "$DB_HOST_LOCAL" "$OPT_DB_PASS"
    panel_configure_env
}

install_wings_flow() {
    run_phase "Dependensi Docker" wings_dependencies
    run_phase "Mengunduh binary Wings" wings_install_binary
    run_phase "Service systemd Wings" wings_service
    run_phase "User database host" wings_dbhost
    run_phase "Sertifikat SSL Wings" wings_ssl
}

uninstall_flow() {
    if [ -x "$ARKAN_BIN" ]; then
        exec "$ARKAN_BIN" uninstall
    fi
    die "Instalasi ArkanProjects tidak ditemukan. Tidak ada yang bisa dihapus."
}

main() {
    HAS_TTY=0
    [ -t 1 ] && HAS_TTY=1

    parse_args "$@"
    DRY_RUN="$OPT_DRY_RUN"
    ASSUME_YES="$OPT_ASSUME_YES"
    setup_colors "$OPT_COLOR"

    banner

    if [ "$OPT_UNINSTALL" -eq 1 ]; then
        require_root
        uninstall_flow
        return 0
    fi

    init_log "$*"
    require_root
    detect_os

    # Mode instalasi
    if [ -z "$OPT_MODE" ]; then
        if [ "$ASSUME_YES" -eq 1 ]; then
            die "Mode belum dipilih. Gunakan --panel, --wings, atau --both."
        fi
        interactive_menu
    fi

    case "$OPT_MODE" in
        panel) INSTALL_PANEL=true ;;
        wings) INSTALL_WINGS=true ;;
        both) INSTALL_PANEL=true; INSTALL_WINGS=true ;;
    esac

    # Versi terbaru
    if need_cmd curl; then
        PANEL_VERSION=$(latest_release "pterodactyl/panel" || true)
        WINGS_VERSION=$(latest_release "pterodactyl/wings" || true)
        if [ -n "$PANEL_VERSION" ]; then
            note "Rilis terbaru — Panel ${PANEL_VERSION} · Wings ${WINGS_VERSION}"
        fi
    fi

    preflight_checks

    collect_shared_options

    if [ "$INSTALL_PANEL" = true ]; then
        collect_panel_settings
    fi

    if [ "$INSTALL_WINGS" = true ] && [ "$INSTALL_PANEL" = false ]; then
        collect_wings_settings
        [ -n "$OPT_TIMEZONE" ] || OPT_TIMEZONE="Asia/Jakarta"
    fi

    check_existing
    print_plan

    if [ "$DRY_RUN" -eq 1 ]; then
        warn "Mode dry-run: tidak ada perubahan yang dilakukan."
        return 0
    fi

    if [ "$ASSUME_YES" -eq 0 ]; then
        local lanjut
        lanjut=$(ask_yesno "Lanjutkan instalasi sekarang?" y)
        [ "$lanjut" = y ] || die "Instalasi dibatalkan."
    fi

    STEP_TOTAL=0
    STEP_INDEX=0
    log "Mulai: mode=${OPT_MODE} fqdn=${OPT_FQDN} ssl=${CONFIGURE_LETSENCRYPT} firewall=${CONFIGURE_FIREWALL}"

    firewall_phase

    if [ "$INSTALL_PANEL" = true ]; then
        section "INSTALASI PANEL"
        STEP_TOTAL=7
        STEP_INDEX=0
        install_panel_flow
    fi

    if [ "$INSTALL_WINGS" = true ]; then
        if [ "$INSTALL_PANEL" = true ]; then
            section "KONFIGURASI WINGS (MESIN SAMA)"
            CONFIGURE_DBHOST=false
            OPT_DBHOST="tidak"
        fi
        section "INSTALASI WINGS"
        STEP_TOTAL=5
        STEP_INDEX=0
        install_wings_flow
    fi

    section "FINALISASI"
    setup_logrotate
    write_runtime_config
    install_arkan_cli

    print_completion
    log "Instalasi selesai dalam $((SECONDS - INSTALL_START)) detik"
}

main "$@"
