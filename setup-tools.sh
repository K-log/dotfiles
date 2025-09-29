#!/usr/bin/env bash

# Setup system tools required by Neovim, its plugins, and developer tooling.
# Supports Debian/Ubuntu, Arch, Fedora, macOS (Homebrew).

set -euo pipefail

FORCE=false
DRY_RUN=false
VERBOSE=false
PRETEND=false

_usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

Options:
  -f, --force       Run non-interactively (assume yes)
  -d, --dry-run     Show what would be done without making changes
  -v, --verbose     Print verbose output
  -p, --plan        Print the exact install commands that would be run (plan) and exit
  -h, --help        Show this help

This script installs system packages and tools used by Neovim/plugins and developer workflow:
  neovim, python3/pip, node/npm, ripgrep (rg), fd, fzf, make, gcc, git, curl,
  lazygit, gh (GitHub CLI), lua, luarocks, openjdk (java), z, oh-my-zsh

Supported OS: Debian/Ubuntu, Arch/Manjaro, Fedora, macOS (Homebrew required).
EOF
}

log() { if [[ "$VERBOSE" == true ]]; then printf "[INFO] %s\n" "$*"; fi }
run() {
  if [[ "$PRETEND" == true ]]; then
    printf "[PLAN] %s\n" "$*"
    return 0
  fi
  if [[ "$DRY_RUN" == true ]]; then
    printf "[DRY-RUN] %s\n" "$*"
  else
    if [[ "$VERBOSE" == true ]]; then
      printf "[RUN] %s\n" "$*"
    fi
    eval "$*"
  fi
}

confirm_prompt() {
  if [[ "$FORCE" == true || "$DRY_RUN" == true ]]; then
    return 0
  fi
  read -rp "$1 (y/N): " ans || return 1
  ans=$(printf '%s' "$ans" | tr '[:upper:]' '[:lower:]')
  [[ "$ans" == "y" ]]
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

package_to_command() {
  # Map package name to a command to check for idempotency
  local pkg="$1"
  case "$pkg" in
    neovim) printf 'nvim' ;;
    python3|python3-venv|python3-pip) printf 'python3' ;;
    nodejs|node) printf 'node' ;;
    npm) printf 'npm' ;;
    ripgrep|rg) printf 'rg' ;;
    fd|fd-find) printf 'fd' ;;
    fzf) printf 'fzf' ;;
    git) printf 'git' ;;
    curl) printf 'curl' ;;
    make) printf 'make' ;;
    gcc) printf 'gcc' ;;
    default-jdk|openjdk|java-11-openjdk|jdk-openjdk) printf 'java' ;;
    lua|lua5.3) printf 'lua' ;;
    luarocks) printf 'luarocks' ;;
    lazygit) printf 'lazygit' ;;
    gh|github-cli) printf 'gh' ;;
    *) printf '%s' "$pkg" ;;
  esac
}

build_install_list() {
  # Inputs: PKGS array
  # Outputs: NEEDS array (global)
  NEEDS=()
  SKIPPED_BY_PKG_MANAGER=()
  local p cmd
  for p in "${PKGS[@]}"; do
    cmd=$(package_to_command "$p")
    if command_exists "$cmd"; then
      log "Skipping $p; $cmd already present"
      continue
    fi
    # If command not present, check package manager if package already installed
    if package_installed "$p"; then
      log "Skipping $p; package manager reports it installed"
      SKIPPED_BY_PKG_MANAGER+=("$p")
      continue
    fi
    NEEDS+=("$p")
  done
}

package_installed() {
  # Return 0 if package (by package name) is installed according to package manager
  local pkg="$1"
  local dpkgname
  dpkgname=$(distro_pkg_name "$pkg")
  case "$OS" in
    debian)
      dpkg -s "$dpkgname" >/dev/null 2>&1 && return 0 || return 1
      ;;
    arch)
      pacman -Q "$dpkgname" >/dev/null 2>&1 && return 0 || return 1
      ;;
    fedora)
      # Use dnf to account for modular or non-rpm entries
      if command -v dnf >/dev/null 2>&1; then
        dnf list installed "$dpkgname" >/dev/null 2>&1 && return 0 || return 1
      else
        rpm -q "$dpkgname" >/dev/null 2>&1 && return 0 || return 1
      fi
      ;;
    mac)
      if command -v brew >/dev/null 2>&1; then
        brew list --formula | grep -x "$dpkgname" >/dev/null 2>&1 && return 0 || return 1
      else
        return 1
      fi
      ;;
    *)
      return 1
      ;;
  esac
}

distro_pkg_name() {
  # Map canonical package names to distro-specific package names when they differ
  # Input: canonical pkg (from PKGS list), Output: package name for package manager
  local pkg="$1"
  case "$OS" in
    debian)
      case "$pkg" in
        fd) printf 'fd-find' ;;
        lua) printf 'lua5.3' ;;
        jdk-openjdk|openjdk) printf 'default-jdk' ;;
        luarocks) printf 'luarocks' ;;
        python-pynvim) printf 'python3-pynvim' ;;
        *) printf '%s' "$pkg" ;;
      esac
      ;;
    arch)
      case "$pkg" in
        python3) printf 'python' ;;
        default-jdk|openjdk) printf 'jdk-openjdk' ;;
        fd-find) printf 'fd' ;;
        lua5.3) printf 'lua' ;;
        python3-pip) printf 'python-pip' ;;
        *) printf '%s' "$pkg" ;;
      esac
      ;;
    fedora)
      case "$pkg" in
        fd) printf 'fd-find' ;;
        lua) printf 'lua' ;;
        default-jdk|openjdk) printf 'java-11-openjdk' ;;
        *) printf '%s' "$pkg" ;;
      esac
      ;;
    mac)
      # Homebrew formula names are often same as canonical; map if known differences
      case "$pkg" in
        python3) printf 'python' ;;
        default-jdk|openjdk) printf 'openjdk' ;;
        fd|fd-find) printf 'fd' ;;
        *) printf '%s' "$pkg" ;;
      esac
      ;;
    *) printf '%s' "$pkg" ;;
  esac
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case $1 in
      -f|--force) FORCE=true; shift ;;
      -d|--dry-run) DRY_RUN=true; shift ;;
      -v|--verbose) VERBOSE=true; shift ;;
      -p|--plan|--pretend) PRETEND=true; shift ;;
      -h|--help) _usage; exit 0 ;;
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

get_aur_helper() {
  for h in yay paru yup; do
    if command -v "$h" >/dev/null 2>&1; then
      printf '%s' "$h"
      return 0
    fi
  done
  return 1
}

install_common_debian() {
  ensure_sudo
  PKGS=(neovim python3 python3-venv python3-pip nodejs npm ripgrep fd-find fzf git curl build-essential make gcc default-jdk lua5.3 luarocks)
  build_install_list
  if [[ ${#NEEDS[@]} -eq 0 ]]; then
    log "All apt packages already present; nothing to install"
    return
  fi
  if [[ ${#SKIPPED_BY_PKG_MANAGER[@]} -gt 0 ]]; then
    printf "[INFO] Packages skipped because package manager reported installed: %s\n" "${SKIPPED_BY_PKG_MANAGER[*]}"
  fi
  echo "About to install missing packages via apt: ${NEEDS[*]}"
  if confirm_prompt "Proceed with apt-get install?"; then
    run "$SUDO apt-get update"
    run "$SUDO apt-get install -y ${NEEDS[*]}"
    if [[ -x "/usr/bin/fdfind" ]] && [[ ! -x "/usr/bin/fd" ]]; then
      run "$SUDO ln -s /usr/bin/fdfind /usr/bin/fd || true"
    fi
    if command -v pip3 >/dev/null 2>&1; then
      run "pip3 install --user pynvim neovim"
    fi
  else
    echo "Skipped apt installation"
  fi
}

install_common_arch() {
  ensure_sudo
  PKGS=(neovim python-pynvim nodejs npm ripgrep fd fzf git curl base-devel make gcc jdk-openjdk lua luarocks)
  build_install_list
  if [[ ${#NEEDS[@]} -eq 0 ]]; then
    log "All pacman packages already present; nothing to install"
  else
    echo "About to install missing packages via pacman: ${NEEDS[*]}"
    if confirm_prompt "Proceed with pacman -S?"; then
      run "$SUDO pacman -Syu --noconfirm --needed ${NEEDS[*]}"
    else
      echo "Skipped pacman installation"
    fi
  fi
  if [[ ${#SKIPPED_BY_PKG_MANAGER[@]} -gt 0 ]]; then
    printf "[INFO] Packages skipped because package manager reported installed: %s\n" "${SKIPPED_BY_PKG_MANAGER[*]}"
  fi
  AUR_HELPER=$(get_aur_helper || true)
  if [[ -n "$AUR_HELPER" ]] && ! command_exists lazygit; then
    run "$AUR_HELPER -S --noconfirm --needed lazygit || true"
  fi
}

install_common_fedora() {
  ensure_sudo
  PKGS=(neovim python3 python3-pip nodejs npm ripgrep fd-find fzf git curl make gcc java-11-openjdk lua luarocks)
  build_install_list
  if [[ ${#NEEDS[@]} -eq 0 ]]; then
    log "All dnf packages already present; nothing to install"
  else
    echo "About to install missing packages via dnf: ${NEEDS[*]}"
    if confirm_prompt "Proceed with dnf install?"; then
      run "$SUDO dnf install -y ${NEEDS[*]}"
    else
      echo "Skipped dnf installation"
    fi
  fi
  if [[ ${#SKIPPED_BY_PKG_MANAGER[@]} -gt 0 ]]; then
    printf "[INFO] Packages skipped because package manager reported installed: %s\n" "${SKIPPED_BY_PKG_MANAGER[*]}"
  fi
  if command -v pip3 >/dev/null 2>&1; then
    run "pip3 install --user pynvim neovim"
  fi
}

install_common_mac() {
  if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew not found. Please install Homebrew from https://brew.sh/ or run this script with --force to attempt automatic install."
    if [[ "$FORCE" == true ]]; then
      if [[ "$DRY_RUN" == true ]]; then
        echo "[DRY-RUN] Would run Homebrew install script"
      else
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      fi
    else
      echo "Abort: Homebrew required on macOS."
      return 1
    fi
  fi
  PKGS=(neovim python node ripgrep fd fzf git curl make openjdk luarocks)
  build_install_list
  if [[ ${#NEEDS[@]} -eq 0 ]]; then
    log "All brew packages already present; nothing to install"
  else
    echo "About to install missing packages via brew: ${NEEDS[*]}"
    if confirm_prompt "Proceed with brew install?"; then
      for p in "${NEEDS[@]}"; do
        run "brew install $p || brew upgrade $p || true"
      done
    else
      echo "Skipped brew installation"
    fi
  fi
  if [[ ${#SKIPPED_BY_PKG_MANAGER[@]} -gt 0 ]]; then
    printf "[INFO] Packages skipped because package manager reported installed: %s\n" "${SKIPPED_BY_PKG_MANAGER[*]}"
  fi
  if command -v pip3 >/dev/null 2>&1; then
    run "pip3 install --user pynvim neovim"
  fi
}

install_oh_my_zsh() {
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    log "oh-my-zsh already present"
    return
  fi
  echo "Installing oh-my-zsh..."
  if [[ "$DRY_RUN" == true ]]; then
    echo "[DRY-RUN] curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | bash"
  else
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || true
  fi
}

install_z_sh() {
  # z (jump around) script
  if [[ -f "$HOME/.local/share/z/z.sh" ]] || [[ -f "$HOME/.zsh/z.sh" ]]; then
    log "z already present"
    return
  fi
  echo "Installing z (z.sh)..."
  if [[ "$DRY_RUN" == true ]]; then
    echo "[DRY-RUN] git clone https://github.com/rupa/z.git ~/.local/share/z"
  else
    git clone https://github.com/rupa/z.git "$HOME/.local/share/z" || true
  fi
}

install_lazygit() {
  if command -v lazygit >/dev/null 2>&1; then
    log "lazygit already installed"
    return
  fi
  echo "Installing lazygit..."
  if [[ "$DRY_RUN" == true ]]; then
    echo "[DRY-RUN] Would fetch latest lazygit release and install binary"
    return
  fi
  LATEST_JSON=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest")
  LATEST_TAG=$(printf '%s' "$LATEST_JSON" | grep -m1 '"tag_name"' | cut -d '"' -f4)
  if [[ -z "$LATEST_TAG" ]]; then
    echo "Failed to determine latest lazygit release" >&2
    return 1
  fi
  OSNAME=$(uname | tr '[:upper:]' '[:lower:]')
  ARCH=$(uname -m)
  case "$ARCH" in
    x86_64|amd64) ARCH_P=amd64 ;;
    aarch64|arm64) ARCH_P=arm64 ;;
    *) ARCH_P="$ARCH" ;;
  esac

  # preferred asset patterns
  CANDIDATES=("lazygit_${LATEST_TAG#v}_${OSNAME}_${ARCH_P}.tar.gz" "lazygit_${LATEST_TAG#v}_${OSNAME}_${ARCH_P}.zip")
  ASSET_URL=""
  for asset in "${CANDIDATES[@]}"; do
    url=$(printf '%s' "$LATEST_JSON" | grep -oE "https:[^"]+${asset}") || true
    if [[ -n "$url" ]]; then
      ASSET_URL="$url"
      break
    fi
  done
  if [[ -z "$ASSET_URL" ]]; then
    # try more generic match
    ASSET_URL=$(printf '%s' "$LATEST_JSON" | grep -oE "https:[^"]+lazygit[^"]+${ARCH_P}[^"]+" | head -n1) || true
  fi
  if [[ -z "$ASSET_URL" ]]; then
    echo "Could not find a compatible lazygit asset for ${OSNAME}/${ARCH_P}" >&2
    return 1
  fi

  TMP=$(mktemp -d /tmp/lazygit.XXXX)
  trap 'rm -rf "$TMP"' RETURN
  curl -L "$ASSET_URL" -o "$TMP/lazygit_asset" || true
  if file "$TMP/lazygit_asset" | grep -qi zip; then
    (cd "$TMP" && unzip -q lazygit_asset) || true
  else
    (cd "$TMP" && tar -xzf lazygit_asset) || true
  fi
  # find binary
  BIN=$(find "$TMP" -type f -name lazygit -perm -111 2>/dev/null | head -n1)
  if [[ -z "$BIN" ]]; then
    # maybe binary is at root named lazygit
    BIN="$TMP/lazygit"
  fi
  if [[ -f "$BIN" ]]; then
    run "sudo cp \"$BIN\" /usr/local/bin/lazygit && sudo chmod +x /usr/local/bin/lazygit"
  else
    echo "Failed to extract lazygit binary from asset" >&2
    return 1
  fi
}

install_gh_cli() {
  if command -v gh >/dev/null 2>&1; then
    log "gh already installed"
    return
  fi
  echo "Installing GitHub CLI (gh)..."
  if [[ "$DRY_RUN" == true ]]; then
    echo "[DRY-RUN] install gh via package manager or https://cli.github.com/"
  else
    case "$OS" in
      debian)
        run "curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg"
        run "sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg"
        run "echo \"deb [arch=$( dpkg --print-architecture ) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main\" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null"
        run "$SUDO apt update"
        run "$SUDO apt install -y gh || true"
        ;;
      arch)
        run "$SUDO pacman -S --noconfirm gh || true"
        ;;
      fedora)
        run "$SUDO dnf install -y 'dnf-plugins-core' || true"
        run "$SUDO dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo || true"
        run "$SUDO dnf install -y gh || true"
        ;;
      mac)
        run "brew install gh || true"
        ;;
    esac
  fi
}

install_java() {
  if command -v java >/dev/null 2>&1; then
    log "java already installed"
    return
  fi
  echo "Installing Java (OpenJDK)..."
  if [[ "$DRY_RUN" == true ]]; then
    echo "[DRY-RUN] install openjdk via package manager"
  else
    case "$OS" in
      debian)
        run "$SUDO apt-get install -y default-jdk || true"
        ;;
      arch)
        run "$SUDO pacman -S --noconfirm jdk-openjdk || true"
        ;;
      fedora)
        run "$SUDO dnf install -y java-11-openjdk || true"
        ;;
      mac)
        run "brew install openjdk || true"
        ;;
    esac
  fi
}

main() {
  parse_args "$@"
  detect_os
  case "$OS" in
    debian) install_common_debian ;;
    arch) install_common_arch ;;
    fedora) install_common_fedora ;;
    mac) install_common_mac ;;
    linux) echo "Generic Linux: please install tools manually." ;;
    *) echo "Unsupported OS: $OS"; exit 1 ;;
  esac

  # Additional installs
  install_oh_my_zsh
  install_z_sh
  install_lazygit
  install_gh_cli
  install_java

  echo "\nSystem tools setup complete (or skipped)."
}

main "$@"
