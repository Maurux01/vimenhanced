" ============================================================
"  vimenhanced - vimrc 100% Vimscript (no Lua)
"  - Line numbers on every line
"  - No ~ on empty lines
"  - Pretty autocomplete + LSP (vim-lsp)
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

" --- 3. Pretty look (Vim only) ---
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

silent! colorscheme habamax
if has('gui_running')
  set guifont=Consolas:h11
  set lines=35 columns=110
endif

highlight Pmenu      ctermfg=255 ctermbg=237 guifg=#eeeeee guibg=#3a3a3a
highlight PmenuSel   ctermfg=16  ctermbg=110 guifg=#000000 guibg=#87afff cterm=bold gui=bold
highlight PmenuSbar  ctermbg=238 guibg=#4a4a4a
highlight PmenuThumb ctermbg=110 guibg=#87afff
highlight CursorLineNr ctermfg=110 cterm=bold guifg=#87afff gui=bold

set statusline=%#PmenuSel#\ %F\ %m%r%h%w\ %*%=%y\ [%{&ff}]\ %l:%c\ %p%%

" --- 4. Pretty native autocomplete ---
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

" Tab / Shift-Tab / Enter (also works with asyncomplete below)
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <CR>    pumvisible() ? asyncomplete#close_popup() : "\<CR>"
inoremap <expr> <Down>  pumvisible() ? "\<C-n>" : "\<Down>"
inoremap <expr> <Up>    pumvisible() ? "\<C-p>" : "\<Up>"
inoremap <C-Space> <C-n>

augroup ClosePreview
  autocmd!
  autocmd CompleteDone * if !pumvisible() | pclose | endif
augroup END

" ============================================================
" --- 5. LSP PLUGINS (Vimscript only, no Lua) ---
" Requires Vim 8.0+ with +job +channel +timers.
" Install with: :PlugInstall
" ============================================================
if has('job') && has('channel') && has('timers')
  " Auto-install vim-plug if missing (Windows and Linux)
  let s:plug_vim = expand('~/.vim/autoload/plug.vim')
  if has('win32') || has('win64')
    let s:plug_vim = expand('~/vimfiles/autoload/plug.vim')
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

  call plug#begin(expand('~/.vim/plugged'))
    Plug 'prabirshrestha/vim-lsp'
    Plug 'mattn/vim-lsp-settings'
    Plug 'prabirshrestha/asyncomplete.vim'
    Plug 'prabirshrestha/asyncomplete-lsp.vim'
    Plug 'prabirshrestha/asyncomplete-file.vim'
    Plug 'prabirshrestha/asyncomplete-buffer.vim'
  call plug#end()

  " --- 5a. asyncomplete: automatic popup while typing ---
  let g:asyncomplete_auto_popup = 1
  let g:asyncomplete_auto_completeopt = 1
  let g:asyncomplete_popup_delay = 200
  au User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#file#get_source_options({
        \ 'name': 'file',
        \ 'allowlist': ['*'],
        \ 'priority': 10,
        \ 'completor': function('asyncomplete#sources#file#completor')
        \ }))
  au User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#buffer#get_source_options({
        \ 'name': 'buffer',
        \ 'allowlist': ['*'],
        \ 'priority': 5,
        \ 'completor': function('asyncomplete#sources#buffer#completor')
        \ }))

  " --- 5b. vim-lsp: behavior ---
  let g:lsp_diagnostics_enabled = 1
  let g:lsp_diagnostics_echo_cursor = 1
  let g:lsp_diagnostics_float_cursor = 1
  let g:lsp_signs_enabled = 1
  let g:lsp_diagnostics_signs_enabled = 1
  let g:lsp_highlights_enabled = 1
  let g:lsp_text_edit_enabled = 1
  let g:lsp_preview_float = 1
  let g:lsp_hover_float = 1
  let g:lsp_completion_enabled = 1

  " Format on save (only if the server supports it)
  "let g:lsp_format_sync_timeout = 1000
  "augroup LspFormat
  "  autocmd!
  "  autocmd BufWritePre *.py,*.sh,*.js,*.ts,*.lua,*.java,*.go call execute('LspDocumentFormatSync')
  "augroup END
endif

" ============================================================
" --- 6. LSP SERVERS BY LANGUAGE (Vimscript) ---
" vim-lsp-settings installs most of them with :LspInstallServer
" Manual registration below is used when the binary is in PATH.
" Install externally with:
"   bash: npm i -g bash-language-server
"   python: pip install python-lsp-server ruff-lsp  (or: npm i -g pyright)
"   go: go install golang.org/x/tools/gopls@latest
"   lua: lua-language-server (winget/scoop/choco, apt, brew)
"   java: jdtls (jdt-language-server, requires Java 17+)
"   js/ts: npm i -g typescript-language-server typescript
"   json/html/css: npm i -g vscode-langservers-extracted
"   vim: npm i -g vim-language-server
"   c/c++: clangd
"   rust: rustup component add rust-analyzer
"   yaml/docker: npm i -g yaml-language-server dockerfile-language-server-nodejs
"   powershell (Windows): winget install Microsoft.PowerShellEditorServices
" ============================================================
augroup LspServers
  autocmd!
  " Only register if vim-lsp exists and the binary is installed
  if exists('*lsp#register_server')
    " Bash
    if executable('bash-language-server')
      autocmd User lsp_setup call lsp#register_server({
            \ 'name': 'bash-ls',
            \ 'cmd': {server_info->['bash-language-server', 'start']},
            \ 'allowlist': ['sh', 'bash'],
            \ })
    endif
    " Python (pylsp > pyright > ruff, uses what you have)
    if executable('pylsp')
      autocmd User lsp_setup call lsp#register_server({
            \ 'name': 'pylsp',
            \ 'cmd': {server_info->['pylsp']},
            \ 'allowlist': ['python'],
            \ })
    endif
    if executable('pyright-langserver')
      autocmd User lsp_setup call lsp#register_server({
            \ 'name': 'pyright',
            \ 'cmd': {server_info->['pyright-langserver', '--stdio']},
            \ 'allowlist': ['python'],
            \ })
    endif
    if executable('ruff-lsp') || executable('ruff')
      autocmd User lsp_setup call lsp#register_server({
            \ 'name': 'ruff',
            \ 'cmd': {server_info-> executable('ruff-lsp') ? ['ruff-lsp'] : ['ruff', 'server']},
            \ 'allowlist': ['python'],
            \ })
    endif
    " Go
    if executable('gopls')
      autocmd User lsp_setup call lsp#register_server({
            \ 'name': 'gopls',
            \ 'cmd': {server_info->['gopls']},
            \ 'allowlist': ['go'],
            \ 'initialization_options': {'usePlaceholders': v:true, 'completeUnimported': v:true},
            \ })
    endif
    " Lua
    if executable('lua-language-server')
      autocmd User lsp_setup call lsp#register_server({
            \ 'name': 'lua-ls',
            \ 'cmd': {server_info->['lua-language-server']},
            \ 'allowlist': ['lua'],
            \ })
    endif
    " Java (jdtls must be in PATH)
    if executable('jdtls')
      autocmd User lsp_setup call lsp#register_server({
            \ 'name': 'jdtls',
            \ 'cmd': {server_info->['jdtls']},
            \ 'allowlist': ['java'],
            \ })
    endif
    " JS / TS
    if executable('typescript-language-server')
      autocmd User lsp_setup call lsp#register_server({
            \ 'name': 'tsserver',
            \ 'cmd': {server_info->['typescript-language-server', '--stdio']},
            \ 'allowlist': ['javascript', 'javascriptreact', 'typescript', 'typescriptreact'],
            \ })
    endif
    " JSON
    if executable('vscode-json-languageserver')
      autocmd User lsp_setup call lsp#register_server({
            \ 'name': 'json-ls',
            \ 'cmd': {server_info->['vscode-json-languageserver', '--stdio']},
            \ 'allowlist': ['json'],
            \ })
    endif
    " Vimscript
    if executable('vim-language-server')
      autocmd User lsp_setup call lsp#register_server({
            \ 'name': 'vim-ls',
            \ 'cmd': {server_info->['vim-language-server', '--stdio']},
            \ 'allowlist': ['vim'],
            \ })
    endif
    " C / C++
    if executable('clangd')
      autocmd User lsp_setup call lsp#register_server({
            \ 'name': 'clangd',
            \ 'cmd': {server_info->['clangd']},
            \ 'allowlist': ['c', 'cpp', 'objc', 'objcpp'],
            \ })
    endif
    " Rust
    if executable('rust-analyzer')
      autocmd User lsp_setup call lsp#register_server({
            \ 'name': 'rust-analyzer',
            \ 'cmd': {server_info->['rust-analyzer']},
            \ 'allowlist': ['rust'],
            \ })
    endif
    " HTML / CSS (separate from JSON)
    if executable('vscode-html-languageserver')
      autocmd User lsp_setup call lsp#register_server({
            \ 'name': 'html-ls',
            \ 'cmd': {server_info->['vscode-html-languageserver', '--stdio']},
            \ 'allowlist': ['html'],
            \ })
    endif
    if executable('vscode-css-languageserver')
      autocmd User lsp_setup call lsp#register_server({
            \ 'name': 'css-ls',
            \ 'cmd': {server_info->['vscode-css-languageserver', '--stdio']},
            \ 'allowlist': ['css', 'scss', 'less'],
            \ })
    endif
    " YAML / Docker
    if executable('yaml-language-server')
      autocmd User lsp_setup call lsp#register_server({
            \ 'name': 'yaml-ls',
            \ 'cmd': {server_info->['yaml-language-server', '--stdio']},
            \ 'allowlist': ['yaml'],
            \ })
    endif
    if executable('docker-langserver')
      autocmd User lsp_setup call lsp#register_server({
            \ 'name': 'docker-ls',
            \ 'cmd': {server_info->['docker-langserver', '--stdio']},
            \ 'allowlist': ['dockerfile'],
            \ })
    endif
  endif
augroup END

" Go format on save (goimports if available, else gofmt)
augroup GoFormat
  autocmd!
  autocmd BufWritePre *.go if executable('goimports') | silent! !goimports -w % | edit! | else | silent! !gofmt -w % | edit! | endif
augroup END

" --- 7. LSP keymaps (only active when a server is attached) ---
function! s:SetupLspMappings() abort
  if exists('*lsp#definition')
    nmap <buffer> gd <plug>(lsp-definition)
    nmap <buffer> gr <plug>(lsp-references)
    nmap <buffer> gi <plug>(lsp-implementation)
    nmap <buffer> gt <plug>(lsp-type-definition)
    nmap <buffer> K  <plug>(lsp-hover)
    nmap <buffer> <leader>rn <plug>(lsp-rename)
    nmap <buffer> <leader>ca <plug>(lsp-code-action)
    nmap <buffer> <leader>f  <plug>(lsp-document-format)
    nmap <buffer> [g <plug>(lsp-previous-diagnostic)
    nmap <buffer> ]g <plug>(lsp-next-diagnostic)
    setlocal omnifunc=lsp#complete
  endif
endfunction
augroup LspKeymaps
  autocmd!
  autocmd User lsp_buffer_enabled call s:SetupLspMappings()
augroup END
