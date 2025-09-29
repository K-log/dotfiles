#!/usr/bin/env bash

# Neovim setup installer
# Installs Neovim and common prerequisites for plugins on Debian, Arch, and macOS.

set -euo pipefail

FORCE=false
DRY_RUN=false
VERBOSE=false
SKIP_INSTALL=false

_usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

Options:
  -f, --force     Run non-interactively (assume yes / use sudo where needed)
  -d, --dry-run   Show what would be done without making changes
  -v, --verbose   Print verbose output
  -s, --skip-install  Skip package installation steps (only run post-install actions)
  -h, --help      Show this help

This script will attempt to install:
  - neovim
  - python3 and python3-pip / python-pynvim or pip-installed pynvim
  - nodejs and npm
  - ripgrep, fd (fd-find), fzf
  - build tools (make, gcc / base-devel)

Supported OS: Debian/Ubuntu, Arch/Manjaro, Fedora (dnf), macOS (Homebrew required).
EOF
}

log() { if [[ "$VERBOSE" == true ]]; then echo "[INFO]" "$@"; fi }
run() {
  if [[ "$DRY_RUN" == true ]]; then
    echo "[DRY-RUN]" "$@"
  else
    if [[ "$VERBOSE" == true ]]; then
      echo "[RUN]" "$@"
    fi
    eval "$@"
  fi
}

confirm() {
  if [[ "$FORCE" == true || "$DRY_RUN" == true ]]; then
    return 0
  fi
  read -rp "$1 (y/N): " ans || return 1
  ans=$(printf '%s' "$ans" | tr '[:upper:]' '[:lower:]')
  [[ "$ans" == "y" ]]
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case $1 in
      -f|--force) FORCE=true; shift ;;
      -d|--dry-run) DRY_RUN=true; shift ;;
      -v|--verbose) VERBOSE=true; shift ;;
  -h|--help) _usage; exit 0 ;;
  -s|--skip-install) SKIP_INSTALL=true; shift ;;
      *) echo "Unknown option: $1"; _usage; exit 1 ;;
    esac
  done
}

detect_os() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="mac"
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if [[ -f /etc/arch-release ]]; then
      OS="arch"
    elif [[ -f /etc/debian_version ]]; then
      OS="debian"
    elif [[ -f /etc/fedora-release ]] || [[ -f /etc/redhat-release ]]; then
      OS="fedora"
    else
      OS="linux"
    fi
  else
    OS="unknown"
  fi
  log "Detected OS: $OS"
}

get_aur_helper() {
  for h in yay paru yup; do
    if command -v "$h" >/dev/null 2>&1; then
      printf '%s' "$h"
      return 0
    fi
  done
  return 1
}

ensure_sudo() {
  if [[ $EUID -ne 0 ]]; then
    if command -v sudo >/dev/null 2>&1; then
      SUDO="sudo"
    else
      echo "This script needs root privileges to install packages. Please run as root or install sudo." >&2
      exit 1
    fi
  else
    SUDO=""
  fi
}

install_debian() {
  # Delegate to setup-tools.sh if present
  if [[ -f "$(dirname "$0")/setup-tools.sh" ]]; then
    TOOLS_SCRIPT="$(dirname "$0")/setup-tools.sh"
    log "Delegating package installs to $TOOLS_SCRIPT"
    CMD="bash $TOOLS_SCRIPT"
    [[ "$FORCE" == true ]] && CMD+=" -f"
    [[ "$DRY_RUN" == true ]] && CMD+=" -d"
    [[ "$VERBOSE" == true ]] && CMD+=" -v"
    run "$CMD"
    return
  fi
  echo "No setup-tools.sh found; run this script with --skip-install to skip package installation or provide setup-tools.sh to manage packages."
}

install_arch() {
  if [[ -f "$(dirname "$0")/setup-tools.sh" ]]; then
    TOOLS_SCRIPT="$(dirname "$0")/setup-tools.sh"
    log "Delegating package installs to $TOOLS_SCRIPT"
    CMD="bash $TOOLS_SCRIPT"
    [[ "$FORCE" == true ]] && CMD+=" -f"
    [[ "$DRY_RUN" == true ]] && CMD+=" -d"
    [[ "$VERBOSE" == true ]] && CMD+=" -v"
    run "$CMD"
    return
  fi
  echo "No setup-tools.sh found; run this script with --skip-install to skip package installation or provide setup-tools.sh to manage packages."
}

install_fedora() {
  if [[ -f "$(dirname "$0")/setup-tools.sh" ]]; then
    TOOLS_SCRIPT="$(dirname "$0")/setup-tools.sh"
    log "Delegating package installs to $TOOLS_SCRIPT"
    CMD="bash $TOOLS_SCRIPT"
    [[ "$FORCE" == true ]] && CMD+=" -f"
    [[ "$DRY_RUN" == true ]] && CMD+=" -d"
    [[ "$VERBOSE" == true ]] && CMD+=" -v"
    run "$CMD"
    return
  fi
  echo "No setup-tools.sh found; run this script with --skip-install to skip package installation or provide setup-tools.sh to manage packages."
}

install_mac() {
  if [[ -f "$(dirname "$0")/setup-tools.sh" ]]; then
    TOOLS_SCRIPT="$(dirname "$0")/setup-tools.sh"
    log "Delegating package installs to $TOOLS_SCRIPT"
    CMD="bash $TOOLS_SCRIPT"
    [[ "$FORCE" == true ]] && CMD+=" -f"
    [[ "$DRY_RUN" == true ]] && CMD+=" -d"
    [[ "$VERBOSE" == true ]] && CMD+=" -v"
    run "$CMD"
    return
  fi
  echo "No setup-tools.sh found; run this script with --skip-install to skip package installation or provide setup-tools.sh to manage packages."
}

main() {
  parse_args "$@"
  detect_os
    # Write a log of required packages before attempting installation
    log_required_packages() {
      local TOOLS_SCRIPT DIR LOGFILE
      DIR="$(dirname "$0")"
      LOGFILE="$PWD/setup-tools-plan-${OS}.log"
      if [[ -f "$DIR/setup-tools.sh" ]]; then
        TOOLS_SCRIPT="$DIR/setup-tools.sh"
        echo "Logging required package plan to: $LOGFILE"
        if [[ "$DRY_RUN" == true ]]; then
          echo "[DRY-RUN] Would run: bash $TOOLS_SCRIPT --plan | tee \"$LOGFILE\""
        else
          bash "$TOOLS_SCRIPT" --plan | tee "$LOGFILE"
        fi
        return
      fi

      # fallback: write simple package lists per OS
      echo "Logging required package list to: $LOGFILE"
      if [[ "$DRY_RUN" == true ]]; then
        echo "[DRY-RUN] Would write package list for $OS to $LOGFILE"
        return
      fi
      case "$OS" in
        debian)
          cat >"$LOGFILE" <<EOF
  apt packages:
  neovim python3 python3-venv python3-pip nodejs npm ripgrep fd-find fzf git curl build-essential make gcc default-jdk lua5.3 luarocks
  EOF
          ;;
        arch)
          cat >"$LOGFILE" <<EOF
  pacman packages:
  neovim python-pynvim nodejs npm ripgrep fd fzf git curl base-devel make gcc jdk-openjdk lua luarocks
  EOF
          ;;
        fedora)
          cat >"$LOGFILE" <<EOF
  dnf packages:
  neovim python3 python3-pip nodejs npm ripgrep fd-find fzf git curl make gcc java-11-openjdk lua luarocks
  EOF
          ;;
        mac)
          cat >"$LOGFILE" <<EOF
  brew packages:
  neovim python node ripgrep fd fzf git curl make openjdk luarocks
  EOF
          ;;
        *)
          echo "Generic Linux: please consult setup-tools.sh or your distro's package manager" >"$LOGFILE"
          ;;
      esac
    }

    log_required_packages
  if [[ "$SKIP_INSTALL" == true ]]; then
    echo "Skipping package installation as requested (--skip-install)."
  else
    case "$OS" in
      debian) install_debian ;;
      arch) install_arch ;;
      fedora) install_fedora ;;
      mac) install_mac ;;
      linux) echo "Generic Linux: please install neovim and prerequisites via your distro package manager."; exit 1 ;;
      *) echo "Unsupported OS: $OS"; exit 1 ;;
    esac
  fi

  echo "\nNeovim prerequisite installation step complete (or skipped)."
  echo "Next: run ./setup-dotfiles.sh to link config files (if not already)."
}

main "$@"
