set relativenumber number
set showmode
set colorcolumn=80
set scrolloff=15

" better search
set hlsearch
set incsearch
set smartcase

" format preferences
set expandtab
set tabstop=2
set shiftwidth=2
set autoindent

set visualbell
set autosave


" use system keyboard
set clipboard+=unnamed

" Homebrew - OSX only
set rtp+=/opt/homebrew/opt/fzf

"colorscheme elflord

let mapleader = ' '

inoremap jk <Esc>

" Easy visual indentation
vnoremap < <gv
vnoremap > >gv

" Pane navigation
nnoremap <A-h> <C-w>h
nnoremap <A-l> <C-w>l
nnoremap <A-k> <C-w>k
nnoremap <A-j> <C-w>j
