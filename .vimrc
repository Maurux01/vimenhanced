" ============================================================
"  vimenhanced - vimrc 100% Vimscript (no Lua, no LSP)
"  - Line numbers on every line
"  - No ~ on empty lines
"  - Dark themes: gruvbox / catppuccin / habamax (<leader>th to cycle)
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
  call plug#begin(s:plug_dir)
    " Dark themes (all dark)
    Plug 'morhetz/gruvbox'
    Plug 'catppuccin/vim', { 'as': 'catppuccin' }
    " Auto-close "" '' {} [] () (pure Vimscript)
    Plug 'jiangmiao/auto-pairs'
  call plug#end()
endif

" --- 5. Themes: gruvbox / catppuccin (mocha) / habamax, all dark ---
" Change with: :ThemeGruvbox | :ThemeCatppuccin | :ThemeHabamax
" or cycle with <leader>th (default leader is \)
let g:vimenhanced_theme = get(g:, 'vimenhanced_theme', 'gruvbox')
let s:themes = ['gruvbox', 'catppuccin_mocha', 'habamax']

" gruvbox options (must be set before colorscheme)
let g:gruvbox_contrast_dark = 'hard'
let g:gruvbox_invert_selection = 0
" catppuccin options (vim port)
let g:catppuccin_flavour = 'mocha'

" NOTE: colorscheme clears ALL highlights, so Mode* + Pmenu must be
" re-applied after every :colorscheme. Keep them in one function.
function! VimenhancedHighlights() abort
  highlight Pmenu      ctermfg=255 ctermbg=237 guifg=#eeeeee guibg=#3a3a3a
  highlight PmenuSel   ctermfg=16  ctermbg=110 guifg=#000000 guibg=#87afff cterm=bold gui=bold
  highlight PmenuSbar  ctermbg=238 guibg=#4a4a4a
  highlight PmenuThumb ctermbg=110 guibg=#87afff
  highlight CursorLineNr ctermfg=110 cterm=bold guifg=#87afff gui=bold
  highlight MatchParen cterm=bold gui=bold ctermfg=220 guifg=#e5c07b ctermbg=238 guibg=#4a4a4a
  highlight ModeNormal  ctermfg=16 ctermbg=110 cterm=bold guifg=#000000 guibg=#87afff gui=bold
  highlight ModeInsert  ctermfg=16 ctermbg=150 cterm=bold guifg=#000000 guibg=#a9dc76 gui=bold
  highlight ModeVisual  ctermfg=16 ctermbg=176 cterm=bold guifg=#000000 guibg=#d19df0 gui=bold
  highlight ModeReplace ctermfg=16 ctermbg=203 cterm=bold guifg=#000000 guibg=#e06c75 gui=bold
  highlight ModeCommand ctermfg=16 ctermbg=221 cterm=bold guifg=#000000 guibg=#e5c07b gui=bold
  highlight ModeOther   ctermfg=16 ctermbg=247 cterm=bold guifg=#000000 guibg=#9e9e9e gui=bold
  " pretty base statusline to match dark themes
  highlight StatusLine   ctermfg=255 ctermbg=237 guifg=#eeeeee guibg=#3a3a3a
  highlight StatusLineNC ctermfg=247 ctermbg=235 guifg=#9e9e9e guibg=#2a2a2a
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
  let l:next = s:themes[(l:idx + 1) % len(s:themes)]
  call VimenhancedTheme(l:next)
  echo 'theme: ' . l:next
endfunction

command! ThemeGruvbox    call VimenhancedTheme('gruvbox')
command! ThemeCatppuccin call VimenhancedTheme('catppuccin_mocha')
command! ThemeHabamax    call VimenhancedTheme('habamax')
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

" --- 6. Syntax highlight extras ---
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

" --- 7. Pretty native autocomplete (no plugins) ---
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

" --- 8. Auto-close "" '' {} [] () ---
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
