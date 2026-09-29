" ============================================================
"  vimenhanced - vimrc 100% Vimscript (no Lua, no LSP)
"  - Line numbers on every line
"  - No ~ on empty lines
"  - Dark-only themes (<leader>th to cycle, :ThemeHelp to list)
"  - Syntax highlight + auto-close "" '' {} [] ()
"  - Pretty autocomplete popup (native, no plugins needed)
" ============================================================

" --- Basics ---
set nocompatible
syntax on
filetype plugin indent on
set encoding=utf-8
set backspace=indent,eol,start
set hidden
set history=200
set updatetime=300
set timeoutlen=400

" --- 1. Line numbers ---
set number
"set relativenumber   " uncomment for relative numbers
set numberwidth=4
set ruler
set showcmd

" --- 2. Hide ~ on empty lines ---
set fillchars=eob:\ 
augroup HideTildes
  autocmd!
  autocmd ColorScheme,VimEnter * highlight! link EndOfBuffer Ignore
  autocmd ColorScheme,VimEnter * highlight! link NonText Ignore
augroup END

" --- 3. Pretty look ---
if has('termguicolors')
  set termguicolors
endif
set background=dark
set cursorline
set laststatus=2
set showmode
set signcolumn=yes
set shortmess+=c
set belloff=all
set novisualbell
if has('gui_running')
  set guifont=Consolas:h11
  set lines=35 columns=110
endif

" --- 4. Plugins (Vimscript only, no Lua, no LSP) ---
" vim-plug bootstrap (Windows and Linux)
let s:plug_vim = expand('~/.vim/autoload/plug.vim')
let s:plug_dir = expand('~/.vim/plugged')
if has('win32') || has('win64')
  let s:plug_vim = expand('~/vimfiles/autoload/plug.vim')
  let s:plug_dir = expand('~/vimfiles/plugged')
endif
if empty(glob(s:plug_vim))
  if has('win32') || has('win64')
    silent! !powershell -NoProfile -Command "New-Item -ItemType Directory -Force $HOME/vimfiles/autoload | Out-Null; Invoke-WebRequest -UseBasicParsing https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim -OutFile $HOME/vimfiles/autoload/plug.vim"
  else
    silent! !curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  endif
  augroup PlugBootstrap
    autocmd!
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
  augroup END
endif

if filereadable(s:plug_vim)
  try
    call plug#begin(s:plug_dir)
    " Dark-only themes (no light themes)
    Plug 'morhetz/gruvbox'
    Plug 'catppuccin/vim', { 'as': 'catppuccin' }
    Plug 'dracula/vim', { 'as': 'dracula' }
    Plug 'joshdick/onedark.vim'
    Plug 'arcticicestudio/nord-vim'
    Plug 'sainnhe/gruvbox-material'
    Plug 'sainnhe/everforest'
    Plug 'sainnhe/sonokai'
    Plug 'tomasr/molokai'
    Plug 'ghifarit53/tokyonight-vim'
    " Auto-close "" '' {} [] () (pure Vimscript)
    Plug 'jiangmiao/auto-pairs'
    call plug#end()
  catch
    " plug.vim unreadable in this session (e.g. -u NONE): skip plugins
  endtry
endif

" --- 5. Dark-only themes ---
" Cycle with <leader>th (default leader is \). List with :ThemeHelp.
" Each theme below is dark-only (background=dark is enforced).
let g:vimenhanced_theme = get(g:, 'vimenhanced_theme', 'gruvbox')
let s:themes = ['gruvbox', 'catppuccin_mocha', 'habamax', 'dracula', 'onedark', 'nord', 'gruvbox-material', 'everforest', 'sonokai', 'molokai', 'tokyonight']

" Theme options (must be set before :colorscheme)
let g:gruvbox_contrast_dark = 'hard'
let g:gruvbox_invert_selection = 0
let g:catppuccin_flavour = 'mocha'
let g:gruvbox_material_background = 'hard'
let g:gruvbox_material_foreground = 'original'
let g:everforest_background = 'hard'
let g:sonokai_style = 'andromeda'
let g:tokyonight_style = 'storm'
let g:onedark_termcolors = 256

" Per-theme accent palette. Statusline, mode labels, popup menu and
" banner all read from here, so every color follows the active scheme.
" Keys: normal / insert / visual / replace / command / other / fg /
" st_bg / st_nc / pmenu_bg
let s:palettes = {
      \ 'gruvbox':          {'normal': '#83a598', 'insert': '#b8bb26', 'visual': '#d3869b', 'replace': '#fb4934', 'command': '#fabd2f', 'other': '#a89984', 'fg': '#ebdbb2', 'st_bg': '#3c3836', 'st_nc': '#282828', 'pmenu_bg': '#3c3836'},
      \ 'catppuccin_mocha': {'normal': '#89b4fa', 'insert': '#a6e3a1', 'visual': '#cba6f7', 'replace': '#f38ba8', 'command': '#f9e2af', 'other': '#bac2de', 'fg': '#cdd6f4', 'st_bg': '#313244', 'st_nc': '#181825', 'pmenu_bg': '#313244'},
      \ 'habamax':           {'normal': '#87afff', 'insert': '#a9dc76', 'visual': '#d19df0', 'replace': '#e06c75', 'command': '#e5c07b', 'other': '#9e9e9e', 'fg': '#eeeeee', 'st_bg': '#3a3a3a', 'st_nc': '#2a2a2a', 'pmenu_bg': '#3a3a3a'},
      \ 'dracula':           {'normal': '#bd93f9', 'insert': '#50fa7b', 'visual': '#ff79c6', 'replace': '#ff5555', 'command': '#f1fa8c', 'other': '#8be9fd', 'fg': '#f8f8f2', 'st_bg': '#44475a', 'st_nc': '#282a36', 'pmenu_bg': '#44475a'},
      \ 'onedark':           {'normal': '#61afef', 'insert': '#98c379', 'visual': '#c678dd', 'replace': '#e06c75', 'command': '#e5c07b', 'other': '#5c6370', 'fg': '#abb2bf', 'st_bg': '#3e4452', 'st_nc': '#282c34', 'pmenu_bg': '#3e4452'},
      \ 'nord':              {'normal': '#88c0d0', 'insert': '#a3be8c', 'visual': '#b48ead', 'replace': '#bf616a', 'command': '#ebcb8b', 'other': '#81a1c1', 'fg': '#eceff4', 'st_bg': '#3b4252', 'st_nc': '#2e3440', 'pmenu_bg': '#3b4252'},
      \ 'gruvbox-material':  {'normal': '#7daea3', 'insert': '#a9b665', 'visual': '#d3869b', 'replace': '#ea6962', 'command': '#d8a657', 'other': '#a89984', 'fg': '#d4be98', 'st_bg': '#3c3836', 'st_nc': '#1d2021', 'pmenu_bg': '#3c3836'},
      \ 'everforest':        {'normal': '#7fbbb3', 'insert': '#a7c080', 'visual': '#d699b6', 'replace': '#e67e80', 'command': '#dbbc7f', 'other': '#859289', 'fg': '#d3c6aa', 'st_bg': '#3d484d', 'st_nc': '#2b3339', 'pmenu_bg': '#3d484d'},
      \ 'sonokai':           {'normal': '#76cce0', 'insert': '#a7df78', 'visual': '#b39df3', 'replace': '#fc5d7c', 'command': '#e7c664', 'other': '#9aa8e3', 'fg': '#e1e3e4', 'st_bg': '#3b3841', 'st_nc': '#221f22', 'pmenu_bg': '#3b3841'},
      \ 'molokai':           {'normal': '#66d9ef', 'insert': '#a6e22e', 'visual': '#ae81ff', 'replace': '#f92672', 'command': '#e6db74', 'other': '#a59f85', 'fg': '#f8f8f2', 'st_bg': '#3b3a32', 'st_nc': '#1b1d1e', 'pmenu_bg': '#3b3a32'},
      \ 'tokyonight':        {'normal': '#7aa2f7', 'insert': '#9ece6a', 'visual': '#bb9af7', 'replace': '#f7768e', 'command': '#e0af68', 'other': '#565f89', 'fg': '#c0caf5', 'st_bg': '#24283b', 'st_nc': '#1a1b26', 'pmenu_bg': '#24283b'},
      \ }

function! VimenhancedPalette() abort
  if has_key(s:palettes, g:vimenhanced_theme)
    return s:palettes[g:vimenhanced_theme]
  endif
  return s:palettes['habamax']
endfunction

" NOTE: colorscheme clears ALL highlights, so Mode* + Pmenu + StatusLine
" + Banner must be re-applied after every :colorscheme.
function! VimenhancedHighlights() abort
  let l:p = VimenhancedPalette()
  execute 'highlight Pmenu      ctermfg=255 ctermbg=237 guifg=' . l:p.fg . ' guibg=' . l:p.pmenu_bg
  execute 'highlight PmenuSel   ctermfg=16  ctermbg=110 cterm=bold guifg=#000000 guibg=' . l:p.normal . ' gui=bold'
  execute 'highlight PmenuSbar  ctermbg=238 guibg=' . l:p.st_nc
  execute 'highlight PmenuThumb ctermbg=110 guibg=' . l:p.normal
  execute 'highlight CursorLineNr ctermfg=110 cterm=bold guifg=' . l:p.normal . ' gui=bold'
  execute 'highlight MatchParen cterm=bold gui=bold guifg=' . l:p.command . ' guibg=' . l:p.st_bg
  execute 'highlight ModeNormal  ctermfg=16 ctermbg=110 cterm=bold guifg=#000000 guibg=' . l:p.normal . ' gui=bold'
  execute 'highlight ModeInsert  ctermfg=16 ctermbg=150 cterm=bold guifg=#000000 guibg=' . l:p.insert . ' gui=bold'
  execute 'highlight ModeVisual  ctermfg=16 ctermbg=176 cterm=bold guifg=#000000 guibg=' . l:p.visual . ' gui=bold'
  execute 'highlight ModeReplace ctermfg=16 ctermbg=203 cterm=bold guifg=#000000 guibg=' . l:p.replace . ' gui=bold'
  execute 'highlight ModeCommand ctermfg=16 ctermbg=221 cterm=bold guifg=#000000 guibg=' . l:p.command . ' gui=bold'
  execute 'highlight ModeOther   ctermfg=16 ctermbg=247 cterm=bold guifg=#000000 guibg=' . l:p.other . ' gui=bold'
  execute 'highlight StatusLine   ctermfg=255 ctermbg=237 guifg=' . l:p.fg . ' guibg=' . l:p.st_bg
  execute 'highlight StatusLineNC ctermfg=247 ctermbg=235 guifg=' . l:p.other . ' guibg=' . l:p.st_nc
  execute 'highlight BannerVim guifg=' . l:p.normal . ' guibg=NONE ctermfg=110 ctermbg=NONE cterm=bold gui=bold'
  execute 'highlight BannerSub guifg=' . l:p.fg . ' guibg=NONE ctermfg=255 ctermbg=NONE'
  execute 'highlight BannerDim guifg=' . l:p.other . ' guibg=NONE ctermfg=247 ctermbg=NONE'
endfunction

augroup VimenhancedHighlights
  autocmd!
  autocmd ColorScheme * call VimenhancedHighlights()
augroup END

function! VimenhancedTheme(name) abort
  let g:vimenhanced_theme = a:name
  set background=dark
  silent! execute 'colorscheme ' . a:name
  call VimenhancedHighlights()
endfunction

function! VimenhancedNextTheme() abort
  let l:idx = index(s:themes, g:vimenhanced_theme)
  if l:idx < 0
    let l:idx = 0
  endif
  let l:next = s:themes[(l:idx + 1) % len(s:themes)]
  call VimenhancedTheme(l:next)
  echo 'theme: ' . l:next
endfunction

function! VimenhancedThemeHelp() abort
  echo 'Dark themes: ' . join(s:themes, ', ')
  echo 'Use :Theme<Rab><Tab> or <leader>th to cycle. Current: ' . g:vimenhanced_theme
endfunction

command! ThemeGruvbox         call VimenhancedTheme('gruvbox')
command! ThemeCatppuccin      call VimenhancedTheme('catppuccin_mocha')
command! ThemeHabamax         call VimenhancedTheme('habamax')
command! ThemeDracula         call VimenhancedTheme('dracula')
command! ThemeOnedark         call VimenhancedTheme('onedark')
command! ThemeNord            call VimenhancedTheme('nord')
command! ThemeGruvboxMaterial call VimenhancedTheme('gruvbox-material')
command! ThemeEverforest      call VimenhancedTheme('everforest')
command! ThemeSonokai         call VimenhancedTheme('sonokai')
command! ThemeMolokai         call VimenhancedTheme('molokai')
command! ThemeTokyonight      call VimenhancedTheme('tokyonight')
command! ThemeHelp            call VimenhancedThemeHelp()
command! ThemeNext            call VimenhancedNextTheme()
nnoremap <silent> <leader>th :call VimenhancedNextTheme()<CR>

" Apply saved theme (silent until :PlugInstall downloads them)
silent! call VimenhancedTheme(g:vimenhanced_theme)

" Current mode label: NORMAL / INSERT / VISUAL / V-LINE / V-BLOCK / etc.
function! StatusModeLabel() abort
  let l:m = mode()
  if l:m ==# 'n' | return 'NORMAL'
  elseif l:m ==# 'i' | return 'INSERT'
  elseif l:m ==# 'R' | return 'REPLACE'
  elseif l:m ==# 'v' | return 'VISUAL'
  elseif l:m ==# 'V' | return 'V-LINE'
  elseif l:m ==# "\<C-v>" | return 'V-BLOCK'
  elseif l:m ==# 's' || l:m ==# 'S' || l:m ==# "\<C-s>" | return 'SELECT'
  elseif l:m ==# 'c' | return 'COMMAND'
  elseif l:m ==# 't' | return 'TERMINAL'
  else | return 'NORMAL'
  endif
endfunction

" Full statusline builder. MUST run via %! (not %{...}) so that
" %#Group# color switches are parsed instead of printed literally.
" Pretty layout: [MODE] file [+] ... filetype | line:col % through file
function! VimenhancedStatusLine() abort
  let l:label = StatusModeLabel()
  if l:label ==# 'INSERT'
    let l:mode_hl = '%#ModeInsert#'
  elseif l:label ==# 'VISUAL' || l:label ==# 'V-LINE' || l:label ==# 'V-BLOCK' || l:label ==# 'SELECT'
    let l:mode_hl = '%#ModeVisual#'
  elseif l:label ==# 'REPLACE'
    let l:mode_hl = '%#ModeReplace#'
  elseif l:label ==# 'COMMAND'
    let l:mode_hl = '%#ModeCommand#'
  elseif l:label ==# 'TERMINAL'
    let l:mode_hl = '%#ModeOther#'
  else
    let l:mode_hl = '%#ModeNormal#'
  endif
  let l:fname = expand('%:t') !=# '' ? expand('%:t') : '[No Name]'
  let l:modified = &modified ? '  ●' : ''
  let l:readonly = &readonly ? '  🔒' : ''
  let l:ft = &filetype !=# '' ? &filetype : '—'
  return l:mode_hl . '  ' . l:label . '  ' . '%*'
        \ . '  ' . l:fname . l:modified . l:readonly . '  '
        \ . '%=' . '  ' . l:ft . '  │  '
        \ . line('.') . ':' . col('.') . '  │  ' . line('$') . 'L  '
endfunction

" Redraw the statusline as soon as the mode changes
augroup StatusModeRefresh
  autocmd!
  if exists('##ModeChanged')
    autocmd ModeChanged * redrawstatus
  else
    autocmd InsertEnter,InsertLeave,CmdlineEnter,CmdlineLeave * redrawstatus
  endif
augroup END

set statusline=%!VimenhancedStatusLine()

" --- 6. VIM ASCII banner (start screen, English only) ---
" Shows a big VIM logo when Vim starts with no file.
" Reopen anytime with :Banner or <leader>st.
function! VimenhancedBanner() abort
  enew
  setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile
  setlocal nonumber norelativenumber nocursorline noshowcmd noruler
  setlocal filetype=vimenhanced-banner
  let l:art = [
        \ '',
        \ '',
        \ '__      _______ __  __',
        \ '\ \    / /_ _|  \/  |',
        \ ' \ \  / / | || |\/| |',
        \ '  \ \/ /  | || |  | |',
        \ '   \_/   |___|_|  |_|',
        \ '',
        \ 'v i m e n h a n c e d',
        \ '100% Vimscript - no Lua, no LSP - dark only',
        \ '',
        \ 'Type  :e <file>  to edit a file',
        \ '      :ThemeHelp  to list dark themes',
        \ '      <leader>th  to cycle themes',
        \ '      :PlugInstall  to manage plugins',
        \ '',
        \ 'Press q, i or o to start editing',
        \ ]
  call setline(1, l:art)
  " Center each line in the current window
  let l:width = winwidth(0)
  for l:n in range(1, line('$'))
    let l:line = getline(l:n)
    let l:pad = (l:width - strwidth(l:line)) / 2
    if l:pad > 0
      call setline(l:n, repeat(' ', l:pad) . l:line)
    endif
  endfor
  setlocal nomodifiable readonly nomodified
  " Banner colors follow the active theme (see VimenhancedHighlights)
  if has_key(s:palettes, g:vimenhanced_theme)
    call VimenhancedHighlights()
  endif
  syntax clear
  syntax match BannerVim /^[ ]*__.*$/ contains=NONE
  syntax match BannerVim /^[ ]*\\.*|.*$/ contains=NONE
  syntax match BannerSub /^[ ]*v i m e n h a n c e d$/
  syntax match BannerDim /^[ ]*100%.*$/
  syntax match BannerDim /^[ ]*Type.*$/
  syntax match BannerDim /^[ ]*Press.*$/
  syntax match BannerDim /^[ ]*:.*$/
  syntax match BannerDim /^[ ]*<leader>.*$/
  nnoremap <silent> <buffer> q :enew<CR>
  nnoremap <silent> <buffer> i :enew<CR>:startinsert<CR>
  nnoremap <silent> <buffer> o :enew<CR>
  nnoremap <silent> <buffer> <CR> :enew<CR>
endfunction

command! Banner call VimenhancedBanner()
nnoremap <silent> <leader>st :Banner<CR>

augroup VimenhancedStart
  autocmd!
  autocmd VimEnter * if argc() == 0 && bufname('') ==# '' && getline(1) ==# '' && line('$') == 1 | call VimenhancedBanner() | endif
augroup END

" --- 7. Syntax highlight extras ---
syntax enable
set showmatch
set matchtime=2
set hlsearch
set incsearch
highlight Search ctermfg=16 ctermbg=221 guifg=#000000 guibg=#e5c07b

augroup FiletypeIndent
  autocmd!
  autocmd FileType python,javascript,typescript,go,rust,c,cpp,java,lua,sh,bash,vim,html,css,json,yaml setlocal shiftwidth=2 tabstop=2 expandtab
augroup END

" --- 8. Pretty native autocomplete (no plugins) ---
set complete=.,w,b,u,t
set completeopt=menu,menuone,noinsert,noselect,popup
set pumheight=10
if exists('+completepopup')
  set completepopup=border:off,highlight:Pmenu
endif
if exists('+pumborder')
  set pumborder=rounded
endif

set wildmenu
set wildmode=longest:full,full
if exists('+wildoptions')
  set wildoptions=pum,tagfile
endif

augroup FiletypeOmni
  autocmd!
  autocmd FileType python     setlocal omnifunc=python3complete#Complete
  autocmd FileType javascript,typescript,css,html,json setlocal omnifunc=syntaxcomplete#Complete
  autocmd FileType vim        setlocal omnifunc=vimcomplete#Complete
  autocmd FileType c,cpp      setlocal omnifunc=ccomplete#Complete
  autocmd FileType xml        setlocal omnifunc=xmlcomplete#Complete
augroup END

" Tab / Shift-Tab / Enter (native popup only, no asyncomplete)
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <CR>    pumvisible() ? "\<C-y>" : "\<CR>"
inoremap <expr> <Down>  pumvisible() ? "\<C-n>" : "\<Down>"
inoremap <expr> <Up>    pumvisible() ? "\<C-p>" : "\<Up>"
inoremap <C-Space> <C-n>

augroup ClosePreview
  autocmd!
  autocmd CompleteDone * if !pumvisible() | pclose | endif
augroup END

" --- 9. Auto-close "" '' {} [] () ---
" Main engine: auto-pairs plugin (pure Vimscript).
" Fallback below only loads if the plugin is missing (fresh install
" before first :PlugInstall), so typing quotes/brackets never breaks.
let g:AutoPairsFlyMode = 0
let g:AutoPairsShortcutFastWrap = '<C-e>'

if !exists('g:AutoPairsLoaded')
  inoremap <silent> " ""<Left>
  inoremap <silent> ' ''<Left>
  inoremap <silent> ( ()<Left>
  inoremap <silent> [ []<Left>
  inoremap <silent> { {}<Left>
  inoremap <silent> {<CR> {<CR>}<ESC>O
endif
