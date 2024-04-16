set relativenumber number
set hlsearch
set incsearch
set showmode
set smartcase
set expandtab
set tabstop=2
set shiftwidth=2
set autoindent
set belloff=all
set clipboard=unnamedplus
set colorcolumn=80
set rtp+=/opt/homebrew/opt/fzf
colorscheme elflord



if has('ide')
  set ideamarks
  set ideaput

  let mapleader = ' '

  " Install the AceJump plugin 
  Plug 'easymotion/vim-easymotion'

  Plug 'terryma/vim-multiple-cursors'
  
  Plug 'tpope/vim-commentary'

  Plug 'tpope/vim-surround'

  Plug 'machakann/vim-highlightedyank'

 " Enable plugins
  set sneak
  
  " Can cause conflicts with mappings
  " set surround

  " Install the IdeaVim-Quickscope plugin in idea
  " Must be enabled after sneak
  set quickscope
  set easymotion
  set multiple-cursors
  "set commentary
  set highlightedyank


  " Install the which-plugin in idea
  set whichkey
  set notimeout

  let g:highlightedyank_highlight_duration = "1000"

  let g:qs_highlight_on_keys = ['f', 'F', 't', 'T', 's', 'S']


  map f <Plug>Sneak-f
  map F <Plug>Sneak-F
  map t <Plug>Sneak-t
  map T <Plug>Sneak-T
  

  let g:WhichKey_SortOrder = "by_key_prefix_first"
  let g:WhichKey_ShowVimActions = "true"

  let g:WhichKeyDesc_windows = "<leader>w +Windows"
  let g:WhichKeyDesc_windows_delete = "<leader>wd delete"
  let g:WhichKeyDesc_windows_split_h = "<leader>ws Split horizontal"
  let g:WhichKeyDesc_windows_split_v = "<leader>wv Split Vertical"
  let g:WhichKeyDesc_windows_maximize = "<leader>wm maximize"


  let g:WhichKeyDesc_action = "<leader>a +Actions"
  let g:WhichKeyDesc_action_editor_context_info = "<leader>am "
  map <leader>am <Action>(EditorContextInfo)


  let g:WhichKeyDesc_comments = "<leader>gcc Comment by line"
  map <leader>gcc <Action>(CommentByLine)

endif
