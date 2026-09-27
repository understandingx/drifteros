#!/usr/bin/env bash
#
# DrifterOS: set up the extras, on Linux.
#
# The DrifterOS executable carries everything it needs to run: Node, the web
# desktop, the Terminal's native addon and the compiler for installed apps. A
# few features use programs your system already installs and keeps patched,
# and shipping our own copies would only give you a second, older one. This
# script checks for them, says in one line what each is for, and offers to
# install what is missing through your own package manager (apt, dnf, pacman
# or zypper), one item at a time.
#
# Nothing is installed without your yes (or --yes). Nothing is downloaded from
# anywhere but your package manager. Nothing that costs money is offered. What
# your package manager does not carry is explained, with the vendor's own
# instructions, and left to you. Running it again changes nothing that is
# already there.
#
# docs/guide/dependencies.md has the full list and the reasons.

set -u

PRODUCT="DrifterOS"
GLIBC_FLOOR="2.28"
NODE_FLOOR=18

usage() {
  cat <<'EOF'
DrifterOS setup for Linux: checks the programs some features use and offers
to install the missing ones with your package manager.

Usage: ./setup.sh [options]

  --check, -c      report only, install nothing (also --dry-run)
  --yes, -y        install every missing RECOMMENDED item without asking
                   (also DRIFTER_SETUP_YES=1); never waits for an answer
  --all, -a        with --yes, the OPTIONAL items too
  --only IDS       only these items, comma separated (with --yes they are
                   installed whatever their tier)
  --desktop        check the desktop app's libraries even with no display
  --no-color       plain output (also NO_COLOR=1)
  --help, -h       this text

Items: browser git node procps desktop-libs fuse xdg-utils notify fonts
       ollama python containers gcloud aws

Exit codes: 0 ready; 1 something recommended is still missing; 2 bad
arguments; 3 this system cannot run DrifterOS; 4 an install you agreed to
failed.

With no terminal to ask in and no --yes, nothing is installed: the missing
items are listed and the exit code says whether any is recommended.
EOF
}

# ------------------------------------------------------------------ arguments
CHECK_ONLY=0
ASSUME_YES=0
INCLUDE_OPTIONAL=0
ONLY=""
FORCE_DESKTOP=0
NO_COLOR_FLAG=0
ALL_ITEMS="browser git node procps desktop-libs fuse xdg-utils notify fonts ollama python containers gcloud aws"

# DRIFTER_SETUP_YES=1 (or true/yes) is --yes, for unattended runs.
case "${DRIFTER_SETUP_YES:-}" in 1|true|TRUE|True|yes|YES|Yes) ASSUME_YES=1 ;; esac

while [ $# -gt 0 ]; do
  case "$1" in
    --check|-c|--dry-run) CHECK_ONLY=1 ;;
    --yes|-y)     ASSUME_YES=1 ;;
    --all|-a)     INCLUDE_OPTIONAL=1 ;;
    --desktop)    FORCE_DESKTOP=1 ;;
    --no-color)   NO_COLOR_FLAG=1 ;;
    --only)
      if [ $# -lt 2 ]; then printf 'setup.sh: --only needs a list of items (try --help)\n' >&2; exit 2; fi
      ONLY="$2"; shift ;;
    --only=*)     ONLY="${1#--only=}" ;;
    --help|-h)    usage; exit 0 ;;
    *) printf 'setup.sh: unknown option %s (try --help)\n' "$1" >&2; exit 2 ;;
  esac
  shift
done

ONLY=$(printf '%s' "$ONLY" | tr ',' ' ')
for id in $ONLY; do
  case " $ALL_ITEMS " in
    *" $id "*) ;;
    *) printf 'setup.sh: unknown item "%s". Items: %s\n' "$id" "$ALL_ITEMS" >&2; exit 2 ;;
  esac
done

# ----------------------------------------------------------------- appearance
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ] && [ "$NO_COLOR_FLAG" -eq 0 ] && [ "${TERM:-dumb}" != "dumb" ]; then
  BOLD=$(printf '\033[1m'); DIM=$(printf '\033[2m'); RED=$(printf '\033[31m')
  GREEN=$(printf '\033[32m'); YELLOW=$(printf '\033[33m'); RESET=$(printf '\033[0m')
else
  BOLD=""; DIM=""; RED=""; GREEN=""; YELLOW=""; RESET=""
fi
ok()    { printf '  %s[ok]%s   %s\n' "$GREEN" "$RESET" "$1"; }
miss()  { printf '  %s[--]%s   %s\n' "$RED" "$RESET" "$1"; }
warn()  { printf '  %s[!!]%s   %s\n' "$YELLOW" "$RESET" "$1"; }
info()  { printf '  %s[ii]%s   %s\n' "$DIM" "$RESET" "$1"; }
note()  { printf '         %s%s%s\n' "$DIM" "$1" "$RESET"; }
head_() { printf '\n%s%s%s\n' "$BOLD" "$1" "$RESET"; }

# ------------------------------------------------------------------- platform
if [ "$(uname -s)" != "Linux" ]; then
  printf 'This script is for Linux. On macOS run setup.command, on Windows setup.cmd.\n' >&2
  exit 2
fi

OS_NAME="Linux"
OS_ID=""
if [ -r /etc/os-release ]; then
  # shellcheck disable=SC1091
  OS_NAME=$(. /etc/os-release && printf '%s' "${PRETTY_NAME:-Linux}")
  OS_ID=$(. /etc/os-release && printf '%s' "${ID:-}")
fi

# a >= b for dotted versions (bash 3 compatible)
ver_ge() {
  a="$1"; b="$2"
  IFS=. read -r a1 a2 a3 <<EOF
$a
EOF
  IFS=. read -r b1 b2 b3 <<EOF
$b
EOF
  a1=${a1:-0}; a2=${a2:-0}; a3=${a3:-0}; b1=${b1:-0}; b2=${b2:-0}; b3=${b3:-0}
  a1=${a1%%[!0-9]*}; a2=${a2%%[!0-9]*}; a3=${a3%%[!0-9]*}
  b1=${b1%%[!0-9]*}; b2=${b2%%[!0-9]*}; b3=${b3%%[!0-9]*}
  [ "${a1:-0}" -gt "${b1:-0}" ] && return 0; [ "${a1:-0}" -lt "${b1:-0}" ] && return 1
  [ "${a2:-0}" -gt "${b2:-0}" ] && return 0; [ "${a2:-0}" -lt "${b2:-0}" ] && return 1
  [ "${a3:-0}" -ge "${b3:-0}" ]
}

printf '%s%s setup%s\n' "$BOLD" "$PRODUCT" "$RESET"
note "$OS_NAME ($(uname -m)), kernel $(uname -r)"

# ------------------------------------------------------------ system checks
# These cannot be installed: they decide whether DrifterOS runs here at all.
head_ "This system"
SYSTEM_OK=1

case "$(uname -m)" in
  x86_64|amd64)  ok "CPU        x64 (drifteros-<version>-linux-x64)" ;;
  aarch64|arm64) ok "CPU        arm64 (drifteros-<version>-linux-arm64)" ;;
  *)             miss "CPU        $(uname -m): DrifterOS is built for x64 and arm64 only"; SYSTEM_OK=0 ;;
esac

GLIBC=$(getconf GNU_LIBC_VERSION 2>/dev/null | awk '{print $2}')
if [ -n "$GLIBC" ]; then
  if ver_ge "$GLIBC" "$GLIBC_FLOOR"; then
    ok "glibc      $GLIBC (needs $GLIBC_FLOOR or newer)"
  else
    miss "glibc      $GLIBC: DrifterOS needs $GLIBC_FLOOR or newer (Ubuntu 20.04+, Debian 11+, Fedora 36+, RHEL 8+)"
    SYSTEM_OK=0
  fi
elif ldd --version 2>&1 | grep -qi musl; then
  miss "C library  musl (Alpine and similar): DrifterOS needs glibc $GLIBC_FLOOR or newer"
  SYSTEM_OK=0
else
  warn "glibc      could not tell which C library this is; DrifterOS needs glibc $GLIBC_FLOOR or newer"
fi

if [ "$SYSTEM_OK" -eq 0 ]; then
  head_ "DrifterOS cannot run on this system"
  printf '  Nothing to install would change that. docs/guide/dependencies.md lists what is supported.\n\n'
  exit 3
fi

HAS_DISPLAY=0
if [ -n "${DISPLAY:-}" ] || [ -n "${WAYLAND_DISPLAY:-}" ] || [ "$FORCE_DESKTOP" -eq 1 ]; then HAS_DISPLAY=1; fi
if [ "$HAS_DISPLAY" -eq 1 ]; then
  info "desktop    a graphical session: the desktop app's libraries are checked too"
else
  info "desktop    no display (a server?): the desktop app's items are skipped (--desktop checks them)"
fi

# Ubuntu 23.10+ (AppArmor 4) forbids unprivileged user namespaces unless a
# profile allows them, which Chromium's sandbox needs.
USERNS_NOTE=0
if [ "$(cat /proc/sys/kernel/apparmor_restrict_unprivileged_userns 2>/dev/null)" = "1" ]; then USERNS_NOTE=1; fi
if [ "$(cat /proc/sys/kernel/unprivileged_userns_clone 2>/dev/null)" = "0" ]; then USERNS_NOTE=1; fi
if [ "$USERNS_NOTE" -eq 1 ] && [ "$HAS_DISPLAY" -eq 1 ]; then
  info "sandbox    user namespaces are restricted here (AppArmor): install the desktop app's .deb,"
  note "           whose post-install adds an AppArmor profile for it; the AppImage cannot"
fi

# ------------------------------------------------------------------ discovery
# PATH first, then the places packages and installers put programs that a
# service started outside your shell might not have on its PATH.
SEARCH_DIRS="/usr/local/bin /usr/bin /bin /usr/sbin /sbin /snap/bin ${HOME:-/root}/.local/bin"

find_bin() {
  for name in "$@"; do
    found=$(command -v "$name" 2>/dev/null) && case "$found" in /*) printf '%s' "$found"; return 0 ;; esac
    for dir in $SEARCH_DIRS; do
      if [ -x "$dir/$name" ] && [ ! -d "$dir/$name" ]; then printf '%s' "$dir/$name"; return 0; fi
    done
  done
  return 1
}

first_line() { "$@" 2>&1 | head -n 1; }

has_lib() {
  lib="$1"
  if command -v ldconfig >/dev/null 2>&1 || [ -x /sbin/ldconfig ]; then
    LDC=$(command -v ldconfig 2>/dev/null || printf '/sbin/ldconfig')
    "$LDC" -p 2>/dev/null | grep -q "$lib" && return 0
  fi
  for d in /usr/lib /usr/lib64 /lib /lib64 /usr/lib/x86_64-linux-gnu /usr/lib/aarch64-linux-gnu /lib/x86_64-linux-gnu /lib/aarch64-linux-gnu; do
    [ -e "$d/$lib" ] && return 0
  done
  return 1
}

# ---------------------------------------------------------------- the items
tier_of() {
  case "$1" in
    browser|git|node|procps|desktop-libs|xdg-utils) printf 'recommended' ;;
    *) printf 'optional' ;;
  esac
}

label_of() {
  case "$1" in
    browser)      printf 'Browser engine' ;;
    git)          printf 'git' ;;
    node)         printf 'Node.js + npm' ;;
    procps)       printf 'ps (procps)' ;;
    desktop-libs) printf 'Desktop app libraries' ;;
    fuse)         printf 'libfuse2' ;;
    xdg-utils)    printf 'xdg-open' ;;
    notify)       printf 'notify-send' ;;
    fonts)        printf 'CJK fonts' ;;
    ollama)       printf 'Ollama' ;;
    python)       printf 'Python 3 + pip' ;;
    containers)   printf 'Container engine' ;;
    gcloud)       printf 'Google Cloud CLI' ;;
    aws)          printf 'AWS CLI' ;;
  esac
}

why_of() {
  case "$1" in
    browser)      printf 'the Browser app and web browsing by agents drive Chrome, Brave, Edge or Chromium' ;;
    git)          printf 'code repositories, and the projects agents build and version for you' ;;
    node)         printf 'most MCP servers (npx), custom services and the web projects agents build' ;;
    procps)       printf 'the Task Manager and the Browser app read running processes with ps' ;;
    desktop-libs) printf 'GTK, NSS, GBM, ALSA and CUPS, which the desktop app (Electron) loads at start' ;;
    fuse)         printf 'the desktop app as an AppImage mounts itself with FUSE 2 (the .deb does not need it)' ;;
    xdg-utils)    printf 'opening links and drifteros:// deep links in your default apps' ;;
    notify)       printf 'desktop notifications when DrifterOS starts with no terminal' ;;
    fonts)        printf 'Chinese text in the desktop app (DrifterOS speaks Chinese; most distributions ship no CJK font)' ;;
    ollama)       printf 'local AI models, on this machine, with no API key' ;;
    python)       printf 'Python projects and tools agents build and run' ;;
    containers)   printf 'building container images for deployments (Podman, with a docker command)' ;;
    gcloud)       printf 'deploying projects to Google Cloud' ;;
    aws)          printf 'deploying projects to AWS' ;;
  esac
}

# A desktop item only matters where the desktop app runs.
applies() {
  case "$1" in
    desktop-libs|fuse|xdg-utils|notify|fonts) [ "$HAS_DISPLAY" -eq 1 ] ;;
    *) return 0 ;;
  esac
}

DETAIL=""
VERSION_NOTE=""

check_item() {
  DETAIL=""; VERSION_NOTE=""
  case "$1" in
    browser)
      if [ -n "${DRIFTER_BROWSER_PATH:-}" ] && [ -x "${DRIFTER_BROWSER_PATH}" ]; then
        DETAIL="$DRIFTER_BROWSER_PATH (DRIFTER_BROWSER_PATH)"; return 0
      fi
      snap_only=""
      for cand in google-chrome google-chrome-stable brave-browser brave microsoft-edge microsoft-edge-stable chromium chromium-browser \
                  /opt/google/chrome/chrome /opt/brave.com/brave/brave /opt/microsoft/msedge/msedge; do
        case "$cand" in /*) [ -x "$cand" ] && b="$cand" || b="" ;; *) b=$(find_bin "$cand") || b="" ;; esac
        [ -n "$b" ] || continue
        case "$(readlink -f "$b" 2>/dev/null || printf '%s' "$b")" in
          /snap/*|*/snap/bin/*) snap_only="$b"; continue ;;
        esac
        DETAIL="$b"; VERSION_NOTE=$(first_line "$b" --version); return 0
      done
      if [ -n "$snap_only" ]; then
        DETAIL="only a snap Chromium ($snap_only), which cannot keep its profile inside ~/.drifter"
      fi
      return 1 ;;
    git)
      # DrifterOS runs DRIFTER_GIT_BIN when it is set, else git from the PATH.
      if [ -n "${DRIFTER_GIT_BIN:-}" ]; then
        case "$DRIFTER_GIT_BIN" in /*) b="$DRIFTER_GIT_BIN" ;; *) b=$(find_bin "$DRIFTER_GIT_BIN") || b="" ;; esac
        if [ -n "$b" ] && [ -x "$b" ]; then DETAIL="$b (DRIFTER_GIT_BIN)"; VERSION_NOTE=$(first_line "$b" --version); return 0; fi
        DETAIL="DRIFTER_GIT_BIN is set to $DRIFTER_GIT_BIN, which is not an executable here"; return 1
      fi
      b=$(find_bin git) || return 1
      DETAIL="$b"; VERSION_NOTE=$(first_line "$b" --version); return 0 ;;
    node)
      b=$(find_bin node nodejs) || return 1
      v=$("$b" --version 2>/dev/null | head -n 1); DETAIL="$b"; VERSION_NOTE="$v"
      major=${v#v}; major=${major%%.*}
      if [ -n "$major" ] && [ "$major" -eq "$major" ] 2>/dev/null && [ "$major" -lt "$NODE_FLOOR" ]; then
        VERSION_NOTE="$v: older than $NODE_FLOOR, which many MCP servers need (nvm or NodeSource have newer)"
      fi
      if ! find_bin npm >/dev/null; then VERSION_NOTE="$VERSION_NOTE; npm is missing"; return 1; fi
      return 0 ;;
    procps)
      b=$(find_bin ps) || return 1
      DETAIL="$b"; return 0 ;;
    desktop-libs)
      missing_libs=""
      for l in libnss3.so libgtk-3.so.0 libgbm.so.1 libasound.so.2 libcups.so.2; do has_lib "$l" || missing_libs="$missing_libs $l"; done
      if [ -z "$missing_libs" ]; then DETAIL="libnss3, libgtk-3, libgbm, libasound, libcups"; return 0; fi
      DETAIL="missing:$missing_libs"; return 1 ;;
    fuse)
      has_lib libfuse.so.2 || return 1
      DETAIL="libfuse.so.2"; return 0 ;;
    xdg-utils)
      b=$(find_bin xdg-open) || return 1
      DETAIL="$b"; return 0 ;;
    notify)
      b=$(find_bin notify-send) || return 1
      DETAIL="$b"; return 0 ;;
    fonts)
      command -v fc-list >/dev/null 2>&1 || { DETAIL="fc-list (fontconfig) is not here to ask"; return 1; }
      f=$(fc-list :lang=zh family 2>/dev/null | head -n 1)
      [ -n "$f" ] || return 1
      DETAIL="${f%%,*}"; return 0 ;;
    ollama)
      # With OLLAMA_BASE_URL set, DrifterOS uses that server and no local Ollama.
      if [ -n "${OLLAMA_BASE_URL:-}" ]; then DETAIL="OLLAMA_BASE_URL=$OLLAMA_BASE_URL (DrifterOS uses that server)"; return 0; fi
      b=$(find_bin ollama) || return 1
      DETAIL="$b"; VERSION_NOTE=$("$b" --version 2>/dev/null | grep -i 'version' | head -n 1)
      # Only this machine's own Ollama port is asked, never the network.
      if command -v curl >/dev/null 2>&1 && ! curl -fsS -m 2 http://127.0.0.1:11434/api/version >/dev/null 2>&1; then
        VERSION_NOTE="${VERSION_NOTE:-installed}; not running (start it: systemctl start ollama, or ollama serve)"
      fi
      return 0 ;;
    python)
      b=$(find_bin python3) || return 1
      DETAIL="$b"; VERSION_NOTE=$(first_line "$b" --version)
      if ! "$b" -m pip --version >/dev/null 2>&1; then VERSION_NOTE="$VERSION_NOTE; pip is missing"; return 1; fi
      return 0 ;;
    containers)
      b=$(find_bin docker podman) || return 1
      DETAIL="$b"; VERSION_NOTE=$(first_line "$b" --version); return 0 ;;
    gcloud)
      b=$(find_bin gcloud) || return 1
      DETAIL="$b"; VERSION_NOTE=$(first_line "$b" --version); return 0 ;;
    aws)
      b=$(find_bin aws) || return 1
      DETAIL="$b"; VERSION_NOTE=$(first_line "$b" --version); return 0 ;;
  esac
  return 1
}

# ----------------------------------------------------------- package manager
PM=""
if   command -v apt-get >/dev/null 2>&1; then PM="apt"
elif command -v dnf     >/dev/null 2>&1; then PM="dnf"
elif command -v pacman  >/dev/null 2>&1; then PM="pacman"
elif command -v zypper  >/dev/null 2>&1; then PM="zypper"
fi

SUDO=""
CAN_INSTALL=1
if [ "$(id -u)" -ne 0 ]; then
  if command -v sudo >/dev/null 2>&1; then SUDO="sudo"; else CAN_INSTALL=0; fi
fi
[ -n "$PM" ] || CAN_INSTALL=0

IS_UBUNTU=0
[ "$OS_ID" = "ubuntu" ] && IS_UBUNTU=1

# On Ubuntu 24.04 some libraries were renamed with a t64 suffix and the old
# name became a virtual package apt refuses to pick: prefer whichever exists.
apt_pick() {
  if apt-cache show "$1" >/dev/null 2>&1; then printf '%s' "$1"; else printf '%s' "$2"; fi
}

# The packages that provide an item with this package manager; empty when the
# package manager does not carry it (then manual_of explains).
packages_of() {
  case "$PM:$1" in
    apt:browser)      [ "$IS_UBUNTU" -eq 1 ] || printf 'chromium' ;;
    dnf:browser|pacman:browser|zypper:browser) printf 'chromium' ;;
    *:git)            printf 'git' ;;
    apt:node|pacman:node) printf 'nodejs npm' ;;
    dnf:node)         printf 'nodejs npm' ;;
    zypper:node)      printf 'nodejs-default npm-default' ;;
    apt:procps|zypper:procps) printf 'procps' ;;
    dnf:procps|pacman:procps) printf 'procps-ng' ;;
    apt:desktop-libs) printf 'libnss3 libgbm1 %s %s %s' "$(apt_pick libgtk-3-0t64 libgtk-3-0)" "$(apt_pick libasound2t64 libasound2)" "$(apt_pick libcups2t64 libcups2)" ;;
    dnf:desktop-libs) printf 'nss gtk3 mesa-libgbm alsa-lib cups-libs' ;;
    pacman:desktop-libs) printf 'nss gtk3 mesa alsa-lib libcups' ;;
    zypper:desktop-libs) printf 'mozilla-nss libgtk-3-0 libgbm1 libasound2 libcups2' ;;
    apt:fuse)         apt_pick libfuse2t64 libfuse2 ;;
    dnf:fuse)         printf 'fuse-libs' ;;
    pacman:fuse)      printf 'fuse2' ;;
    zypper:fuse)      printf 'libfuse2' ;;
    *:xdg-utils)      printf 'xdg-utils' ;;
    apt:notify)       printf 'libnotify-bin' ;;
    dnf:notify|pacman:notify) printf 'libnotify' ;;
    zypper:notify)    printf 'libnotify-tools' ;;
    apt:fonts)        printf 'fonts-noto-cjk' ;;
    dnf:fonts)        printf 'google-noto-sans-cjk-fonts' ;;
    pacman:fonts)     printf 'noto-fonts-cjk' ;;
    zypper:fonts)     printf 'noto-sans-cjk-fonts' ;;
    pacman:ollama)    printf 'ollama' ;;
    apt:python)       printf 'python3 python3-pip python3-venv' ;;
    dnf:python|zypper:python) printf 'python3 python3-pip' ;;
    pacman:python)    printf 'python python-pip' ;;
    *:containers)     printf 'podman podman-docker' ;;
    dnf:aws)          printf 'awscli2' ;;
    pacman:aws)       printf 'aws-cli-v2' ;;
  esac
}

manual_of() {
  case "$1" in
    browser)
      if [ "$IS_UBUNTU" -eq 1 ]; then
        printf "Ubuntu's chromium package is a snap, which cannot keep its profile inside ~/.drifter.\n"
        printf 'Install Google Chrome from its .deb (https://www.google.com/chrome/, then\n'
        printf 'sudo apt install ./google-chrome-stable_current_amd64.deb), or Brave or Edge from theirs.\n'
      else
        printf 'Install Google Chrome, Brave, Edge or Chromium, or point DrifterOS at one in Settings > Internet.\n'
      fi ;;
    node)       printf 'Install Node.js 18 or newer: https://nodejs.org/en/download (nvm or NodeSource).\n' ;;
    ollama)     printf "Ollama's own installer (read it first): curl -fsSL https://ollama.com/install.sh | sh\n"
                printf 'or see https://ollama.com/download/linux\n' ;;
    gcloud)     printf "Google's own package repository: https://cloud.google.com/sdk/docs/install#linux\n"
                printf 'then run: gcloud init\n' ;;
    aws)        printf "The AWS CLI v2 installer: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html\n"
                printf 'then run: aws configure sso\n' ;;
    *)          printf 'Install it with your distribution'"'"'s package manager, then run this script again.\n' ;;
  esac
}

APT_UPDATED=0
pm_install() {
  case "$PM" in
    apt)
      if [ "$APT_UPDATED" -eq 0 ]; then $SUDO apt-get update || return 1; APT_UPDATED=1; fi
      $SUDO env DEBIAN_FRONTEND=noninteractive apt-get install -y "$@" ;;
    dnf)    $SUDO dnf install -y "$@" ;;
    pacman) $SUDO pacman -S --needed --noconfirm "$@" ;;
    zypper) $SUDO zypper --non-interactive install "$@" ;;
    *) return 1 ;;
  esac
}

pm_text() {
  s=""; [ -n "$SUDO" ] && s="sudo "
  case "$PM" in
    apt)    printf '%sapt-get install -y %s' "$s" "$1" ;;
    dnf)    printf '%sdnf install -y %s' "$s" "$1" ;;
    pacman) printf '%spacman -S --needed --noconfirm %s' "$s" "$1" ;;
    zypper) printf '%szypper --non-interactive install %s' "$s" "$1" ;;
  esac
}

# ------------------------------------------------------------ what is here
selected() {
  [ -z "$ONLY" ] && return 0
  case " $ONLY " in *" $1 "*) return 0 ;; esac
  return 1
}

MISSING=""
report_item() {
  id="$1"
  label=$(label_of "$id")
  pad=$(printf '%-22s' "$label")
  if check_item "$id"; then
    ok "$pad $DETAIL"
    [ -n "$VERSION_NOTE" ] && note "$(printf '%-22s' '') $VERSION_NOTE"
    return 0
  fi
  if [ "$(tier_of "$id")" = "recommended" ]; then miss "$pad not found"; else info "$pad not installed (optional)"; fi
  note "$(printf '%-22s' '') $(why_of "$id")"
  [ -n "$DETAIL" ] && note "$(printf '%-22s' '') $DETAIL"
  [ -n "$VERSION_NOTE" ] && note "$(printf '%-22s' '') $VERSION_NOTE"
  MISSING="$MISSING $id"
  return 1
}

for tier in recommended optional; do
  if [ "$tier" = "recommended" ]; then head_ "Recommended"; else head_ "Optional (for specific features)"; fi
  shown=0
  for id in $ALL_ITEMS; do
    [ "$(tier_of "$id")" = "$tier" ] || continue
    selected "$id" || continue
    applies "$id" || continue
    report_item "$id"
    shown=1
  done
  [ "$shown" -eq 1 ] || note "nothing selected"
done

missing_recommended() {
  for id in $MISSING; do [ "$(tier_of "$id")" = "recommended" ] && return 0; done
  return 1
}

if [ -z "$MISSING" ]; then
  head_ "Summary"
  if [ -n "$ONLY" ]; then printf '  Everything you asked about is here. Nothing to do.\n\n'
  else printf '  Everything DrifterOS can use is here. Nothing to do.\n\n'; fi
  exit 0
fi

if [ "$CHECK_ONLY" -eq 1 ]; then
  head_ "Summary"
  printf '  Missing:%s\n' "$MISSING"
  printf '  Run %s./setup.sh%s to install them (each one asks first).\n\n' "$BOLD" "$RESET"
  if missing_recommended; then exit 1; fi
  exit 0
fi

# ------------------------------------------------------------------ install
head_ "Installing"
if [ -z "$PM" ]; then
  note "No package manager this script knows (apt, dnf, pacman, zypper): the steps below are for you to run."
elif [ "$CAN_INSTALL" -eq 0 ]; then
  note "Installing packages needs root, and sudo is not available: the steps below are for you to run as root."
else
  note "Package manager: $PM$([ -n "$SUDO" ] && printf ', through sudo (it may ask for your password)')"
fi

TTY_OK=0
if [ -r /dev/tty ] && { : </dev/tty; } 2>/dev/null; then TTY_OK=1; fi

# With no terminal, sudo cannot ask for a password: use it only when it needs
# none (sudo -n), so an unattended run fails fast instead of waiting.
if [ "$CAN_INSTALL" -eq 1 ] && [ -n "$SUDO" ] && [ "$TTY_OK" -eq 0 ]; then
  if sudo -n true >/dev/null 2>&1; then
    SUDO="sudo -n"
  else
    CAN_INSTALL=0
    note "sudo needs a password and there is no terminal to type it in: the steps below are for you to run."
  fi
fi

ask() {
  # $1 prompt, $2 default (y|n)
  if [ "$TTY_OK" -eq 0 ]; then return 1; fi
  if [ "$2" = "y" ]; then printf '  %s [Y/n] ' "$1"; else printf '  %s [y/N] ' "$1"; fi
  reply=""
  read -r reply </dev/tty || reply=""
  case "$reply" in
    y|Y|yes|YES|Yes) return 0 ;;
    n|N|no|NO|No) return 1 ;;
    "") [ "$2" = "y" ] ;;
    *) return 1 ;;
  esac
}

INSTALLED=""
FAILED=""
MANUAL=""
SKIPPED=""
ASKED_NO_TTY=0

for id in $MISSING; do
  label=$(label_of "$id")
  tier=$(tier_of "$id")
  pkgs=$(packages_of "$id")
  printf '\n  %s%s%s (%s): %s\n' "$BOLD" "$label" "$RESET" "$tier" "$(why_of "$id")"
  if [ -z "$pkgs" ] || [ "$CAN_INSTALL" -eq 0 ]; then
    if [ -n "$pkgs" ] && [ -n "$PM" ]; then note "as root: $(pm_text "$pkgs" | sed 's/^sudo //')"; else manual_of "$id" | while IFS= read -r line; do note "$line"; done; fi
    MANUAL="$MANUAL $id"
    continue
  fi
  note "would run: $(pm_text "$pkgs")"
  go=0
  if [ "$ASSUME_YES" -eq 1 ]; then
    if [ "$tier" = "recommended" ] || [ "$INCLUDE_OPTIONAL" -eq 1 ] || [ -n "$ONLY" ]; then go=1; fi
  else
    default="n"; [ "$tier" = "recommended" ] && default="y"
    if [ "$TTY_OK" -eq 0 ]; then ASKED_NO_TTY=1; elif ask "Install $label?" "$default"; then go=1; fi
  fi
  if [ "$go" -eq 0 ]; then SKIPPED="$SKIPPED $id"; note "skipped"; continue; fi
  # shellcheck disable=SC2086
  if pm_install $pkgs; then
    hash -r 2>/dev/null || true
    if check_item "$id"; then ok "$label  $DETAIL"; INSTALLED="$INSTALLED $id"
    else miss "$label: the package installed, but it is still not found"; FAILED="$FAILED $id"; fi
  else
    miss "$label: $PM failed (its output is above)"
    FAILED="$FAILED $id"
  fi
done

# ------------------------------------------------------------------ summary
head_ "Summary"
[ -n "$INSTALLED" ] && printf '  Installed:        %s\n' "$INSTALLED"
[ -n "$SKIPPED" ]   && printf '  Not installed:    %s\n' "$SKIPPED"
[ -n "$MANUAL" ]    && printf '  Up to you:        %s (the steps are above)\n' "$MANUAL"
[ -n "$FAILED" ]    && printf '  %sFailed:%s           %s\n' "$RED" "$RESET" "$FAILED"
if [ "$ASKED_NO_TTY" -eq 1 ]; then
  printf '  No terminal to ask in: run it in a terminal, or with --yes to install without asking.\n'
fi
[ -n "$INSTALLED" ] && printf '  Restart DrifterOS so it finds what was just installed.\n'
printf '  Run it again with --check at any time.\n\n'

[ -n "$FAILED" ] && exit 4
for id in $MISSING; do
  [ "$(tier_of "$id")" = "recommended" ] || continue
  case " $INSTALLED " in *" $id "*) ;; *) exit 1 ;; esac
done
exit 0
