#!/usr/bin/env bash
# vimenhanced installer for Linux / macOS.
# Installs Vim, Node, Python, Go, vim-plug, LSP servers,
# then copies .vimrc to ~/.vimrc.
#
# Usage:
#   ./install.sh
#   ./install.sh --minimal
#   ./install.sh --no-lsp
#   ./install.sh --only-config
set -euo pipefail

MINIMAL=0
NO_LSP=0
ONLY_CONFIG=0
for arg in "$@"; do
  case "$arg" in
    --minimal) MINIMAL=1 ;;
    --no-lsp) NO_LSP=1 ;;
    --only-config) ONLY_CONFIG=1 ;;
    -h|--help)
      echo "Usage: ./install.sh [--minimal] [--no-lsp] [--only-config]"
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
  sudo apt-get install -y curl ca-certificates gnupg
  if [[ "$MINIMAL" == "1" ]]; then
    sudo apt-get install -y vim git curl
  else
    # Node 22 LTS via NodeSource (apt's nodejs is too old, e.g. v20 -> EBADENGINE).
    # Only use NodeSource if current node is missing or < 22.
    NEED_NODE=1
    if have node; then
      NODE_MAJOR="$(node -p "process.versions.node.split('.')[0]" 2>/dev/null || echo 0)"
      if [[ "$NODE_MAJOR" -ge 22 ]] 2>/dev/null; then
        NEED_NODE=0
      fi
    fi
    if [[ "$NEED_NODE" == "1" ]]; then
      step "Installing Node.js 22 LTS via NodeSource"
      curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
    fi
    sudo apt-get install -y vim git curl nodejs python3 python3-pip golang-go
    # Debian's separate 'npm' package can conflict with NodeSource's bundled npm.
    # NodeSource's nodejs already includes npm, so only install npm package as fallback.
    if ! have npm; then
      sudo apt-get install -y npm
    fi
  fi
}

install_arch() {
  # Arch / Manjaro / EndeavourOS / Artix / CachyOS
  step "Detected Arch family: installing with pacman"
  sudo pacman -Sy --noconfirm --needed \
    vim git curl nodejs npm python python-pip go
  if [[ "$MINIMAL" == "1" ]]; then
    true  # base set above is already minimal enough
  fi
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
        sudo dnf install -y vim git curl nodejs npm python3 python3-pip golang
      elif have apk; then
        sudo apk add vim git curl nodejs npm python3 py3-pip go
      elif have brew; then
        brew install vim git curl node python go
      else
        echo "WARNING: no supported package manager found. Install manually: vim git curl node python3 go" >&2
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
# 4. LSP servers
# ----------------------------------------------------------
if [[ "$NO_LSP" == "1" || "$MINIMAL" == "1" ]]; then
  step "Skipping LSP servers (--no-lsp or --minimal)"
else
  step "Installing LSP servers"
  if have npm; then
    # Fix EACCES: never sudo npm. Use a user-local prefix ~/.npm-global.
    NPM_PREFIX="$HOME/.npm-global"
    mkdir -p "$NPM_PREFIX"
    npm config set prefix "$NPM_PREFIX"
    export PATH="$NPM_PREFIX/bin:$PATH"
    # Persist for future shells
    for RC in "$HOME/.bashrc" "$HOME/.profile"; do
      if [[ -f "$RC" ]] && ! grep -q '\.npm-global/bin' "$RC" 2>/dev/null; then
        echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> "$RC"
      fi
    done
    echo "npm prefix: $(npm config get prefix) ($(node --version 2>/dev/null || echo 'no node'))"
    if have node; then
      NODE_MAJOR="$(node -p "process.versions.node.split('.')[0]" 2>/dev/null || echo 0)"
      if [[ "$NODE_MAJOR" -lt 22 ]] 2>/dev/null; then
        echo "WARNING: node v$NODE_MAJOR detected, LSP servers need Node >= 22. Re-run system install or: curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash - && sudo apt-get install -y nodejs" >&2
      fi
    fi
    npm install -g bash-language-server typescript-language-server typescript \
      vscode-langservers-extracted vim-language-server \
      yaml-language-server dockerfile-language-server-nodejs
  else
    echo "WARNING: npm not found, skipping npm servers." >&2
  fi
  if have python3; then
    # Debian 12+/Ubuntu 23+ are PEP 668 externally-managed, need --break-system-packages
    python3 -m pip install --upgrade pip --break-system-packages 2>/dev/null || python3 -m pip install --upgrade pip || true
    python3 -m pip install python-lsp-server ruff-lsp --break-system-packages 2>/dev/null || python3 -m pip install python-lsp-server ruff-lsp || true
  else
    echo "WARNING: python3 not found, skipping pylsp/ruff." >&2
  fi
  if have go; then
    go install golang.org/x/tools/gopls@latest
  else
    echo "WARNING: go not found, skipping gopls." >&2
  fi
  echo "NOTE: lua-language-server, jdtls (Java 17+), clangd and rust-analyzer are installed separately (see README)."
fi

# ----------------------------------------------------------
# 5. Install Vim plugins headlessly
# ----------------------------------------------------------
if have vim; then
  step "Installing Vim plugins (:PlugInstall)"
  vim -Nu "$DEST" +'PlugInstall --sync' +qall || vim -Nu "$DEST" +PlugInstall +qall || true
else
  echo "WARNING: vim not found. Open Vim later and run :PlugInstall" >&2
fi

echo ""
echo "Done! Open vim and run :LspStatus / :LspInstallServer to check LSP."
