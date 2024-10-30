set relativenumber number
set showmode
set colorcolumn=80
set scrolloff=15

" better search
augroup vimrc-incsearch-highlight
  " enable highlight search only when searching
  autocmd!
  autocmd CmdlineEnter /,\? :set hlsearch
  autocmd CmdlineLeave /,\? :set nohlsearch
augroup END
set incsearch
set smartcase

" format preferences
set expandtab
set tabstop=2
set shiftwidth=2
set autoindent

set visualbell


" Homebrew - OSX only
if has("win32")
  "Windows options here
else
  if has("unix")
    let s:uname = system("uname")
    if s:uname == "Darwin\n"
      set rtp+=/opt/homebrew/opt/fzf
    endif
  endif
endif

colorscheme elflord

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

" use system keyboard
"set clipboard+=unnamedplus
" Copy paste from system clipboard
vmap <C-c> "+yi
vmap <C-x> "+c
vmap <C-v> c<ESC>"+p
imap <C-v> <C-r><C-o>+
