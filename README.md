# vimenhanced

Pretty Vim config in **100% Vimscript (no Lua, no Neovim required)** with line numbers, no `~` noise, a nice autocomplete popup, and optional LSP for many languages.

## Features

- Line numbers (`set number`), ruler, sign column (no layout jumps)
- No `~` on empty lines (`fillchars=eob: ` + `EndOfBuffer` highlight)
- Pretty popup menu (`Pmenu` / `PmenuSel`), `cursorline`, `termguicolors`, mode-aware statusline (`NORMAL` / `INSERT` / `VISUAL` / ...) with per-mode colors
- Pretty autocomplete:
  - Insert mode: `completeopt=menu,menuone,noinsert,noselect,popup`, `pumheight=10`
  - Command line: `wildmenu` + `wildmode=longest:full,full`
  - `Tab` / `Shift-Tab` to navigate, `Enter` to accept, `Ctrl-Space` to trigger
- LSP via `vim-lsp` + `vim-lsp-settings` + `asyncomplete` (all Vimscript):
  - Bash, Python (`pylsp` / `pyright` / `ruff`), Go (`gopls`), Lua, Java (`jdtls`),
    JS/TS, JSON/HTML/CSS, Vimscript, C/C++ (`clangd`), Rust, YAML, Dockerfile

## Files

| File | Purpose |
| ---- | ------- |
| `.vimrc` | Main config (English, Vimscript only) |
| `install.sh` | Linux installer (auto-detects Debian vs Arch) |

## Quick install

```bash
./install.sh
./install.sh --minimal
./install.sh --no-lsp
./install.sh --only-config
```

What it does:

1. Detects your distro via `/etc/os-release`:
   - Debian family (Debian/Ubuntu/Mint/Pop/Kali) → `apt-get`
   - Arch family (Arch/Manjaro/EndeavourOS/Artix/CachyOS) → `pacman`
2. Installs `vim git curl nodejs npm python3 go` with your package manager
3. Installs `vim-plug` to `~/.vim/autoload/plug.vim`
4. Backs up `~/.vimrc` to `~/.vimrc.bak` (once) and copies `.vimrc` to `~/.vimrc`
5. Installs LSP servers with `npm` / `pip` / `go install`
6. Runs `vim +PlugInstall --sync +qall`

## Manual install

1. Install `vim-plug` to `~/.vim/autoload/plug.vim`
   - From <https://github.com/junegunn/vim-plug>
2. Copy `.vimrc` to `~/.vimrc`
3. Open Vim and run `:PlugInstall`

## LSP servers

The config auto-registers a server only if its binary is in `PATH`. Easiest path is `:LspInstallServer` (from `vim-lsp-settings`), or install manually:

| Language | Server binary | Install |
| -------- | ------------- | ------- |
| Bash | `bash-language-server` | `npm i -g bash-language-server` |
| Python | `pylsp` / `pyright-langserver` / `ruff` | `pip install python-lsp-server ruff-lsp` or `npm i -g pyright` |
| Go | `gopls` | `go install golang.org/x/tools/gopls@latest` |
| Lua | `lua-language-server` | winget/scoop/choco, apt, brew |
| Java | `jdtls` | jdt-language-server, requires Java 17+ |
| JS/TS | `typescript-language-server` | `npm i -g typescript-language-server typescript` |
| JSON/HTML/CSS | `vscode-*-languageserver` | `npm i -g vscode-langservers-extracted` |
| Vimscript | `vim-language-server` | `npm i -g vim-language-server` |
| C/C++ | `clangd` | system package / LLVM |
| Rust | `rust-analyzer` | `rustup component add rust-analyzer` |
| YAML/Docker | `yaml-language-server` / `docker-langserver` | `npm i -g yaml-language-server dockerfile-language-server-nodejs` |

Check with `:LspStatus`. Go is also formatted on save with `goimports` (fallback `gofmt`).

## Keymaps

Autocomplete (insert mode):

| Key | Action |
| --- | ------ |
| `Tab` / `Shift-Tab` | Next / previous item |
| `Enter` | Accept selected item |
| `Ctrl-Space` | Trigger completion |
| `Ctrl-X Ctrl-F` | File path completion |
| `Ctrl-X Ctrl-O` | Omni completion |
| `Ctrl-E` / `Ctrl-Y` | Close / accept popup |

LSP (normal mode, buffer-local when a server attaches):

| Key | Action |
| --- | ------ |
| `gd` / `gr` / `gi` / `gt` | Definition / references / implementation / type |
| `K` | Hover |
| `<leader>rn` | Rename |
| `<leader>ca` | Code action |
| `<leader>f` | Format document |
| `[g` / `]g` | Previous / next diagnostic |

## Uninstall

- Delete the copied file (`~/_vimrc` on Windows, `~/.vimrc` on Linux) or restore the `.bak` file.
- Optional: `rm -rf ~/.vim/plugged` (`%USERPROFILE%\vimfiles\plugged` on Windows).

## Troubleshooting

- `:PlugInstall` fails: check internet access to GitHub and that `git` is installed.
- No LSP: run `:LspStatus`, confirm the server binary is in `PATH` (`where` on Windows, `which` on Linux).
- No popup colors: your terminal may not support `termguicolors`; the config degrades gracefully.
