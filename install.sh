#!/usr/bin/env bash
# vimenhanced installer for Linux / macOS.
# Installs Vim, vim-plug, then copies .vimrc to ~/.vimrc.
# No LSP, no Node, no Python packages: themes + syntax + autopairs only.
#
# Usage:
#   ./install.sh
#   ./install.sh --only-config
set -euo pipefail

ONLY_CONFIG=0
for arg in "$@"; do
  case "$arg" in
    --minimal|--no-lsp) ;; # kept for backwards compat, no-op
    --only-config) ONLY_CONFIG=1 ;;
    -h|--help)
      echo "Usage: ./install.sh [--only-config]"
      exit 0
      ;;
    *) echo "Unknown option: $arg" >&2; exit 1 ;;
  esac
done

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$REPO_DIR/.vimrc"
DEST="$HOME/.vimrc"

step() { echo -e "\n==> $1"; }
have() { command -v "$1" >/dev/null 2>&1; }

if [[ ! -f "$SRC" ]]; then
  echo "Missing .vimrc at: $SRC" >&2
  exit 1
fi

# ----------------------------------------------------------
# 1. System dependencies (Debian vs Arch detection)
# ----------------------------------------------------------
detect_distro() {
  # Prints: debian | arch | unknown
  if [[ -f /etc/os-release ]]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    local id="${ID:-unknown}"
    local like="${ID_LIKE:-}"
    case "$id $like" in
      *arch*|*manjaro*|*endeavour*|*artix*|*cachyos*)
        echo "arch" && return 0 ;;
      *debian*|*ubuntu*|*mint*|*pop*|*kali*|*raspbian*)
        echo "debian" && return 0 ;;
    esac
  fi
  # Fallback: guess from available package manager
  if have pacman; then echo "arch";
  elif have apt-get; then echo "debian";
  else echo "unknown"; fi
}

install_debian() {
  # Debian / Ubuntu / Mint / Pop / Kali
  step "Detected Debian family: installing with apt-get"
  sudo apt-get update
  sudo apt-get install -y vim git curl
}

install_arch() {
  # Arch / Manjaro / EndeavourOS / Artix / CachyOS
  step "Detected Arch family: installing with pacman"
  sudo pacman -Sy --noconfirm --needed vim git curl
}

if [[ "$ONLY_CONFIG" == "1" ]]; then
  step "OnlyConfig: skipping system packages"
else
  DISTRO="$(detect_distro)"
  echo "Distro detected: $DISTRO"
  case "$DISTRO" in
    debian) install_debian ;;
    arch) install_arch ;;
    *)
      step "Unknown distro: trying package manager fallback"
      if have apt-get; then install_debian;
      elif have pacman; then install_arch;
      elif have dnf; then
        sudo dnf install -y vim git curl
      elif have apk; then
        sudo apk add vim git curl
      elif have brew; then
        brew install vim git curl
      else
        echo "WARNING: no supported package manager found. Install manually: vim git curl" >&2
      fi
      ;;
  esac
fi

# ----------------------------------------------------------
# 2. vim-plug
# ----------------------------------------------------------
step "Installing vim-plug"
PLUG="$HOME/.vim/autoload/plug.vim"
if [[ ! -f "$PLUG" ]]; then
  curl -fLo "$PLUG" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
else
  echo "vim-plug already installed."
fi

# ----------------------------------------------------------
# 3. Copy .vimrc to the right place
# ----------------------------------------------------------
step "Installing .vimrc"
if [[ -f "$DEST" && ! -f "$DEST.bak" ]]; then
  cp "$DEST" "$DEST.bak"
  echo "Backup: $DEST -> $DEST.bak"
fi
cp "$SRC" "$DEST"
echo "Copied .vimrc -> $DEST"

# ----------------------------------------------------------
# 4. Install Vim plugins headlessly
# ----------------------------------------------------------
if have vim; then
  step "Installing Vim plugins (:PlugInstall)"
  vim -Nu "$DEST" +'PlugInstall --sync' +qall || vim -Nu "$DEST" +PlugInstall +qall || true
else
  echo "WARNING: vim not found. Open Vim later and run :PlugInstall" >&2
fi

echo ""
echo "Done! Open vim and run :PlugStatus to check plugins."
echo "Themes: :ThemeGruvbox | :ThemeCatppuccin | :ThemeHabamax  (cycle with <leader>th)"
