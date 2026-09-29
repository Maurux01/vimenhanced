# vimenhanced

Pretty Vim config in **100% Vimscript (no Lua, no Neovim required, no LSP)** with line numbers, no `~` noise, dark-only changeable themes, VIM ASCII start banner, syntax highlight, auto-close pairs and a nice autocomplete popup.
<img width="1875" height="973" alt="imagen" src="https://github.com/user-attachments/assets/de902e43-36de-408c-b14a-631bba744070" />

## Features

- Line numbers (`set number`), ruler, sign column (no layout jumps)
- No `~` on empty lines (`fillchars=eob: ` + `EndOfBuffer` highlight)
- VIM ASCII start banner on empty startup (`:Banner` or `<leader>st` to reopen, `q` / `i` / `o` to start editing)
- Dark-only themes (11, all dark):
  - `gruvbox` (default), `catppuccin_mocha`, `habamax` (built-in), `dracula`, `onedark`, `nord`, `gruvbox-material`, `everforest`, `sonokai`, `molokai`, `tokyonight`
  - `:ThemeHelp` lists them all, `:ThemeNext` or `<leader>th` (default leader `\`) cycles them
  - Statusline, mode labels (`NORMAL` / `INSERT` / `VISUAL` / ...), popup menu and banner colors all follow the active colorscheme via a per-theme palette
- Syntax highlight: `syntax on` + `showmatch` + `hlsearch`/`incsearch` + 2-space indent per filetype
- Auto-close `"" '' {} [] ()` via `jiangmiao/auto-pairs` (pure Vimscript) + native fallback before first `:PlugInstall`
- Pretty popup menu (`Pmenu` / `PmenuSel`), `cursorline`, `termguicolors`, mode-aware statusline (`NORMAL` / `INSERT` / `VISUAL` / ...) with per-mode colors
- Pretty autocomplete (native, no plugins):
  - Insert mode: `completeopt=menu,menuone,noinsert,noselect,popup`, `pumheight=10`
  - Command line: `wildmenu` + `wildmode=longest:full,full`
  - `Tab` / `Shift-Tab` to navigate, `Enter` to accept, `Ctrl-Space` to trigger

## Files

| File | Purpose |
| ---- | ------- |
| `.vimrc` | Main config (English, Vimscript only) |
| `install.sh` | Linux installer (auto-detects Debian vs Arch, installs `vim git curl` + `vim-plug` + plugins) |

## Quick install

```bash
./install.sh
./install.sh --only-config
```

What it does:

1. Detects your distro via `/etc/os-release`:
   - Debian family (Debian/Ubuntu/Mint/Pop/Kali) → `apt-get`
   - Arch family (Arch/Manjaro/EndeavourOS/Artix/CachyOS) → `pacman`
2. Installs `vim git curl` with your package manager
3. Installs `vim-plug` to `~/.vim/autoload/plug.vim`
4. Backs up `~/.vimrc` to `~/.vimrc.bak` (once) and copies `.vimrc` to `~/.vimrc`
5. Runs `vim +PlugInstall --sync +qall` (themes + autopairs)

## Manual install (plugins window)

1. Install `vim-plug` to `~/.vim/autoload/plug.vim`
   - From <https://github.com/junegunn/vim-plug>
2. Copy `.vimrc` to `~/.vimrc`
3. Open Vim and run:

```vim
:PlugInstall
:PlugStatus
```

Plugins window opens automatically with `:PlugInstall`. Other commands:

| Command | Action |
| ------- | ------ |
| `:PlugInstall` | Install / open plugins window |
| `:PlugStatus` | Check status (all should be `OK`) |
| `:PlugUpdate` | Update plugins |
| `:PlugClean` | Remove unused plugins |

Expected plugins: `gruvbox`, `catppuccin`, `dracula`, `onedark`, `nord-vim`, `gruvbox-material`, `everforest`, `sonokai`, `molokai`, `tokyonight-vim`, `auto-pairs`.

## Keymaps

Start banner:

| Key | Action |
| --- | ------ |
| `<leader>st` or `:Banner` | Reopen VIM ASCII banner |
| `q` / `o` / `Enter` (in banner) | New empty buffer |
| `i` (in banner) | New empty buffer in insert mode |

Autocomplete (insert mode):

| Key | Action |
| --- | ------ |
| `Tab` / `Shift-Tab` | Next / previous item |
| `Enter` | Accept selected item |
| `Ctrl-Space` | Trigger completion |
| `Ctrl-E` | Close popup |

Themes:

| Key / Command | Action |
| ------------- | ------ |
| `<leader>th` or `:ThemeNext` | Cycle through all 11 dark themes |
| `:ThemeHelp` | List all dark themes + current one |
| `:ThemeGruvbox` | Dark gruvbox |
| `:ThemeCatppuccin` | Dark catppuccin mocha |
| `:ThemeHabamax` | Dark habamax (built-in, no plugin) |
| `:ThemeDracula` | Dark dracula |
| `:ThemeOnedark` | Dark onedark |
| `:ThemeNord` | Dark nord |
| `:ThemeGruvboxMaterial` | Dark gruvbox-material |
| `:ThemeEverforest` | Dark everforest |
| `:ThemeSonokai` | Dark sonokai |
| `:ThemeMolokai` | Dark molokai |
| `:ThemeTokyonight` | Dark tokyonight |

Auto-close: just type `" ' ( [ {` and the pair closes automatically (`{<CR>` expands to block).

## Uninstall

- Delete the copied file (`~/_vimrc` on Windows, `~/.vimrc` on Linux) or restore the `.bak` file.
- Optional: `rm -rf ~/.vim/plugged` (`%USERPROFILE%\vimfiles\plugged` on Windows).

## Troubleshooting

- `:PlugInstall` fails: check internet access to GitHub and that `git` is installed.
- No theme colors: your terminal may not support `termguicolors`; the config degrades gracefully. Try `:ThemeHabamax` (built-in).
- Auto-close not working before install: run `:PlugInstall` first, restart Vim.
