# vimenhanced

Pretty Vim config in **100% Vimscript (no Lua, no Neovim required, no LSP)** with line numbers, no `~` noise, dark changeable themes, syntax highlight, auto-close pairs and a nice autocomplete popup.

## Features

- Line numbers (`set number`), ruler, sign column (no layout jumps)
- No `~` on empty lines (`fillchars=eob: ` + `EndOfBuffer` highlight)
- Dark themes, all dark (changeable):
  - `gruvbox` (default), `catppuccin_mocha`, `habamax`
  - `:ThemeGruvbox` | `:ThemeCatppuccin` | `:ThemeHabamax`
  - `<leader>th` (default leader `\`) to cycle
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

Expected plugins: `gruvbox`, `catppuccin`, `auto-pairs`.

## Keymaps

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
| `<leader>th` | Cycle gruvbox → catppuccin_mocha → habamax |
| `:ThemeGruvbox` | Dark gruvbox |
| `:ThemeCatppuccin` | Dark catppuccin mocha |
| `:ThemeHabamax` | Dark habamax |

Auto-close: just type `" ' ( [ {` and the pair closes automatically (`{<CR>` expands to block).

## Uninstall

- Delete the copied file (`~/_vimrc` on Windows, `~/.vimrc` on Linux) or restore the `.bak` file.
- Optional: `rm -rf ~/.vim/plugged` (`%USERPROFILE%\vimfiles\plugged` on Windows).

## Troubleshooting

- `:PlugInstall` fails: check internet access to GitHub and that `git` is installed.
- No theme colors: your terminal may not support `termguicolors`; the config degrades gracefully. Try `:ThemeHabamax` (built-in).
- Auto-close not working before install: run `:PlugInstall` first, restart Vim.
