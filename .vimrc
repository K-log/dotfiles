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

let mapleader = ' '

if has('ide')
  set ideamarks
  set ideaput

  " Install the AceJump plugin 
  Plug 'easymotion/vim-easymotion'

  Plug 'terryma/vim-multiple-cursors'
  
  Plug 'tpope/vim-commentary'

  Plug 'tpope/vim-surround'

  Plug 'machakann/vim-highlightedyank'

 " Enable plugins
  set sneak
  
  " Can cause conflicts with mappings
  set surround

  " Install the IdeaVim-Quickscope plugin in idea
  " Must be enabled after sneak
  set quickscope
  set easymotion
  set multiple-cursors
  "set commentary
  set highlightedyank
  set ReplaceWithRegister

  " Install the which-plugin in idea
  set which-key
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
  let g:WhichKeyDesc_windows_delete = "<leader>wd Close Content"
  nmap <leader>wd <Action>(CloseContent)
  let g:WhichKeyDesc_windows_split = "<leader>ws Split"
  let g:WhichKeyDesc_windows_split_unsplit = "<leader>wsu Unsplit"
  nmap <leader>wsu <Action>(Unsplit)
  let g:WhichKeyDesc_windows_split_h = "<leader>wsh Split Horizontal"
  nmap <leader>wsh <Action>(SplitHorizontally)
  let g:WhichKeyDesc_windows_split_v = "<leader>wsv Split Vertical"
  nmap <leader>wsv <Action>(SplitVertically)
  let g:WhichKeyDesc_windows_maximize = "<leader>wm Maximize"
  nmap <leader>wsm <Action>(MaximizeEditorInSplit)

  let g:WhichKeyDesc_action = "<leader>a +Actions"
  let g:WhichKeyDesc_action_search_everywhere = "<leader>aa Search Everywhere"
  nmap <leader>aa <Action>(SearchEverywhere)
  let g:WhichKeyDesc_action_editor_context_info = "<leader>am Editor Context Info"
  nmap <leader>am <Action>(EditorContextInfo)
  let g:WhichKeyDesc_action_show_hover_info = "<leader>ah Hover Info"
  nmap <leader>ah <Action>(ShowHoverInfo)
  let g:WhichKeyDesc_action_show_intentions = "<leader>ai Show Intentions"
  nmap <leader>ai <Action>(ShowIntentionActions)


  let g:WhichKeyDesc_goto = "<leader>g +Goto"
  let g:WhichKeyDesc_goto_declaration = "<leader>gd Goto Declaration/Usage"
  nmap <leader>gd <Action>(GotoDeclaration)
  let g:WhichKeyDesc_goto_implementation = "<leader>gi Goto Implementation"
  nmap <leader>gi <Action>(GotoImplementation)
  let g:WhichKeyDesc_goto_next_error = "<leader>ge Goto Next Error"
  nmap <leader>ge <Action>(GotoNextError)
  let g:WhichKeyDesc_goto_prev_error = "<leader>gE Goto Prev Error"
  nmap <leader>gE <Action>(GotoPreviousError)
  let g:WhichKeyDesc_goto_file = "<leader>gf Goto File"
  nmap <leader>gf <Action>(GotoFile)

  let g:WhichKeyDesc_easymotion = "<leader><leader> +Easy Motion"

  let g:WhichKeyDesc_comment = "<leader>c +Comments"
  let g:WhichKeyDesc_comment_by_line = "<leader>cl Comment by line"
  map <leader>cl <Action>(CommentByLine)
  let g:WhichKeyDesc_comment_by_block = "<leader>cb Comment by block"
  map <leader>cb <Action>(CommentByBlockComment)

  let g:WhichKeyDesc_file = "<leader>f +File"
  let g:WhichKeyDesc_file_recent_files = "<leader>fr Recent Files"
  nmap <leader>fr <Action>(RecentFiles)
  let g:WhichKeyDesc_file_recent_locations = "<leader>fl Recent Locations"
  nmap <leader>fl <Action>(RecentLocations)
  let g:WhichKeyDesc_file_open = "<leader>ff Find File"
  nmap <leader>ff <Action>(GotoFile)
  let g:WhichKeyDesc_file_new = "<leader>fn New File"
  nmap <leader>fn <Action>(NewFile)
  let g:WhichKeyDesc_file_new_scratch = "<leader>fs New Scratch File"
  nmap <leader>fs <Action>(NewScratchFile)

  nmap <C-n> <Plug>NextWholeOccurrence
  xmap <C-n> <Plug>NextWholeOccurrence
  nmap g<C-n> <Plug>NextOccurrence
  xmap g<C-n> <Plug>NextOccurrence
  xmap <C-x> <Plug>SkipOccurrence
  xmap <C-p> <Plug>RemoveOccurrence

  vmap <S-J> <Action>(MoveLineDown)
  vmap <S-K> <Action>(MoveLineUp)
endif
