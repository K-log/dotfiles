# Neovim Configuration

Personal Neovim configuration with LSP, Treesitter, Telescope, and modern plugin setup.

**Leader Key:** `<space>`

## Table of Contents

- [Keybindings](#keybindings)
  - [Native Neovim - Custom Keybindings](#native-neovim---custom-keybindings)
  - [Native Neovim - Default Keybindings](#native-neovim---default-keybindings)
  - [Plugin Keybindings - Custom](#plugin-keybindings---custom)
  - [Plugin Keybindings - Defaults](#plugin-keybindings---defaults)
- [Plugins](#plugins)
- [Configuration](#configuration)
  - [LSP Servers](#lsp-servers)
  - [Formatters](#formatters)
  - [Treesitter Parsers](#treesitter-parsers)

## Keybindings

### Native Neovim - Custom Keybindings

Custom keybindings for native Neovim functionality.

| Category | Keybinding | Mode | Description |
|----------|------------|------|-------------|
| Buffer Management | `<C-S-h>` | Normal | Previous buffer |
| Buffer Management | `<C-S-l>` | Normal | Next buffer |
| Buffer Management | `<C-S-q>` | Normal | Close current buffer |
| Code Actions | `<leader>ca` | Normal | Code actions (LSP) |
| Code Actions | `<leader>ch` | Normal | Toggle inlay hints (LSP) |
| Code Actions | `<leader>ci` | Normal | Optimize imports (TS/JS LSP) |
| Code Actions | `<leader>cl` | Normal | Lint and format code |
| Code Actions | `<leader>cp` | Normal | Format code (language-aware) |
| Code Actions | `<leader>cre` | Normal | Rename element (LSP) |
| Code Actions | `<leader>crf` | Normal | Rename file |
| Completion | `<C-Space>` | Insert | Trigger completion menu |
| Completion | `<C-j>` | Insert | Select previous completion item |
| Completion | `<C-k>` | Insert | Select next completion item |
| Completion | `<Enter>` | Insert | Confirm completion selection |
| Diagnostics | `<leader>E` | Normal | Jump to previous diagnostic error |
| Diagnostics | `<leader>e` | Normal | Jump to next diagnostic error |
| Diagnostics | `<leader>gg` | Normal | Open diagnostic quickfix list |
| Diagnostics | `<leader>q` | Normal | Open diagnostic quickfix list |
| File Operations | `<leader>fe` | Normal | File explorer (netrw) |
| File Operations | `<leader>fn` | Normal | New file |
| General | `<Esc>` | Normal | Clear search highlights |
| General | `jk` | Insert | Escape to normal mode |
| LSP Features | `<C-h>` | Insert | Signature help while typing |
| LSP Features | `<leader>cd` | Normal | Go to type definition |
| LSP Features | `<leader>cs` | Normal | Signature help |
| LSP Features | `K` | Normal | Hover documentation |
| Movement | `<S-J>` | Normal | Move line down |
| Movement | `<S-J>` | Visual | Move selection down |
| Movement | `<S-K>` | Normal | Move line up |
| Movement | `<S-K>` | Visual | Move selection up |
| Movement | `[[` | Normal | Previous method |
| Movement | `]]` | Normal | Next method |
| Window Management | `<leader>we` | Normal | Expand/maximize window |
| Window Management | `<leader>wh` | Normal | Split horizontally |
| Window Management | `<leader>wm` | Normal | Move window to new tab |
| Window Management | `<leader>wq` | Normal | Quit/close window |
| Window Management | `<leader>wu` | Normal | Unsplit (close all but current) |
| Window Management | `<leader>wv` | Normal | Split vertically |
| Window Navigation | `<C-h>` | Normal | Move focus to the left window |
| Window Navigation | `<C-j>` | Normal | Move focus to the lower window |
| Window Navigation | `<C-k>` | Normal | Move focus to the upper window |
| Window Navigation | `<C-l>` | Normal | Move focus to the right window |

### Native Neovim - Default Keybindings

Common Vim/Neovim default keybindings for reference.

| Category | Keybinding | Mode | Description |
|----------|------------|------|-------------|
| Edit | `.` | Normal | Repeat last change |
| Edit | `<C-r>` | Normal | Redo |
| Edit | `A` | Normal | Insert at end of line |
| Edit | `I` | Normal | Insert at start of line |
| Edit | `O` | Normal | Open line above |
| Edit | `X` | Normal | Delete char before cursor |
| Edit | `a` | Normal | Insert after cursor |
| Edit | `c{motion}` | Normal | Change with motion |
| Edit | `cc` | Normal | Change line |
| Edit | `d{motion}` | Normal | Delete with motion |
| Edit | `dd` | Normal | Delete line |
| Edit | `i` | Normal | Insert before cursor |
| Edit | `o` | Normal | Open line below |
| Edit | `p` | Normal | Paste after cursor |
| Edit | `u` | Normal | Undo |
| Edit | `x` | Normal | Delete char at cursor |
| Edit | `y{motion}` | Normal | Yank with motion |
| Edit | `yy` | Normal | Yank line |
| Motion | `$` | Normal | End of line |
| Motion | `0` | Normal | Start of line |
| Motion | `;` | Normal | Repeat f/F/t/T forward |
| Motion | `,` | Normal | Repeat f/F/t/T backward |
| Motion | `G` | Normal | End of file |
| Motion | `b` | Normal | Word backward |
| Motion | `e` | Normal | Word end |
| Motion | `f{char}` | Normal | Find character forward |
| Motion | `gg` | Normal | Start of file |
| Motion | `h` | Normal | Left |
| Motion | `j` | Normal | Down |
| Motion | `k` | Normal | Up |
| Motion | `l` | Normal | Right |
| Motion | `t{char}` | Normal | Till character forward |
| Motion | `w` | Normal | Word forward |
| Motion | `{` | Normal | Previous paragraph |
| Motion | `}` | Normal | Next paragraph |
| Search | `#` | Normal | Search word under cursor backward |
| Search | `*` | Normal | Search word under cursor forward |
| Search | `/` | Normal | Search forward |
| Search | `?` | Normal | Search backward |
| Search | `N` | Normal | Previous search match |
| Search | `n` | Normal | Next search match |
| Visual | `<C-v>` | Normal | Visual block mode |
| Visual | `V` | Normal | Visual line mode |
| Visual | `v` | Normal | Visual mode (character) |

**Note:** See `:help index` for complete Vim keybinding reference.

### Plugin Keybindings - Custom

Custom keybindings configured for plugins.

#### Telescope

| Category | Keybinding | Mode | Description |
|----------|------------|------|-------------|
| File Operations | `<leader>fb` | Normal | File browser |
| Go To | `<leader>gd` | Normal | Go to definition |
| Go To | `<leader>gi` | Normal | Go to implementation |
| Go To | `<leader>gr` | Normal | Go to references |
| Go To | `<leader>gs` | Normal | Go to document symbols |
| Go To | `<leader>gt` | Normal | Go to type definition |
| Go To | `<leader>gws` | Normal | Go to workspace symbols |
| Search | `<leader>/` | Normal | Fuzzy search in current buffer |
| Search | `<leader>s.` | Normal | Search recent files |
| Search | `<leader>s/` | Normal | Search in open files |
| Search | `<leader>sb` | Normal | Search buffers |
| Search | `<leader>sc` | Normal | Search changed files (git status) |
| Search | `<leader>sd` | Normal | Search diagnostics |
| Search | `<leader>sf` | Normal | Search files |
| Search | `<leader>sg` | Normal | Live grep |
| Search | `<leader>sh` | Normal | Search help tags |
| Search | `<leader>sk` | Normal | Search keymaps |
| Search | `<leader>sn` | Normal | Search neovim config files |
| Search | `<leader>sp` | Normal | Search project files (git) |
| Search | `<leader>sr` | Normal | Resume last search |
| Search | `<leader>ss` | Normal | Search subfolders |
| Search | `<leader>sw` | Normal | Search current word |

**Note:** See `:help telescope.builtin` for more Telescope commands.

#### Harpoon

| Category | Keybinding | Mode | Description |
|----------|------------|------|-------------|
| Harpoon | `<C-1>` | Normal | Jump to harpoon file 1 |
| Harpoon | `<C-2>` | Normal | Jump to harpoon file 2 |
| Harpoon | `<C-3>` | Normal | Jump to harpoon file 3 |
| Harpoon | `<C-4>` | Normal | Jump to harpoon file 4 |
| Harpoon | `<C-S-[>` | Normal | Previous harpoon file |
| Harpoon | `<C-S-]>` | Normal | Next harpoon file |
| Harpoon | `<C-e>` | Normal | Open harpoon window |
| Harpoon | `<leader>ha` | Normal | Add file to harpoon |
| Harpoon | `<leader>ht` | Normal | Toggle harpoon list |
| Harpoon | `<leader>hx` | Normal | Delete file from harpoon |

**Note:** See `:help harpoon` for more Harpoon commands.

#### Treesitter

| Category | Keybinding | Mode | Description |
|----------|------------|------|-------------|
| Treesitter | `<C-space>` | Normal | Incrementally expand selection |
| Treesitter | `<bs>` | Normal | Shrink selection |
| Treesitter | `aa` | Visual/Operator | Select outer parameter |
| Treesitter | `ia` | Visual/Operator | Select inner parameter |

**Note:** `aa`/`ia` text objects work with both Treesitter (parameter selection) and mini.ai (argument selection). `<C-Space>` serves different purposes in Normal mode (Treesitter selection) vs Insert mode (completion trigger). See `:help nvim-treesitter` for more.

#### NvimTree

| Category | Keybinding | Mode | Description |
|----------|------------|------|-------------|
| File Operations | `<leader>nt` | Normal | NvimTree toggle |

**Note:** See `:help nvim-tree-default-mappings` for window keybindings.

#### Which-Key

| Category | Keybinding | Mode | Description |
|----------|------------|------|-------------|
| General | `<leader>?` | Normal | Show all keymaps (which-key) |

**Note:** See `:help which-key.nvim` for more features.

### Plugin Keybindings - Defaults

Default keybindings provided by installed plugins.

#### vim-commentary (tpope/vim-commentary)

| Category | Keybinding | Mode | Description |
|----------|------------|------|-------------|
| Commentary | `gc` | Normal/Visual | Toggle comment (with motion/selection) |
| Commentary | `gcc` | Normal | Toggle comment on current line |
| Commentary | `gcap` | Normal | Toggle comment on paragraph |
| Commentary | `gcu` | Normal | Uncomment adjacent commented lines |

**Note:** See `:help commentary` for full documentation.

#### quick-scope (unblevable/quick-scope)

No keybindings - provides visual highlighting for `f`, `F`, `t`, `T` motions.

**Note:** See `:help quick-scope` for configuration options.

#### vim-easymotion (easymotion/vim-easymotion)

| Category | Keybinding | Mode | Description |
|----------|------------|------|-------------|
| EasyMotion | `<Leader><Leader>B` | Normal | Jump to WORD start backward |
| EasyMotion | `<Leader><Leader>E` | Normal | Jump to WORD end forward |
| EasyMotion | `<Leader><Leader>F{char}` | Normal | Find character backward |
| EasyMotion | `<Leader><Leader>N` | Normal | Jump to latest / or ? backward |
| EasyMotion | `<Leader><Leader>T{char}` | Normal | Till character backward |
| EasyMotion | `<Leader><Leader>W` | Normal | Jump to WORD start forward |
| EasyMotion | `<Leader><Leader>b` | Normal | Jump to word start backward |
| EasyMotion | `<Leader><Leader>e` | Normal | Jump to word end forward |
| EasyMotion | `<Leader><Leader>f{char}` | Normal | Find character forward |
| EasyMotion | `<Leader><Leader>gE` | Normal | Jump to WORD end backward |
| EasyMotion | `<Leader><Leader>ge` | Normal | Jump to word end backward |
| EasyMotion | `<Leader><Leader>j` | Normal | Jump to line below |
| EasyMotion | `<Leader><Leader>k` | Normal | Jump to line above |
| EasyMotion | `<Leader><Leader>n` | Normal | Jump to latest / or ? forward |
| EasyMotion | `<Leader><Leader>s{char}` | Normal | Search character (bidirectional) |
| EasyMotion | `<Leader><Leader>t{char}` | Normal | Till character forward |
| EasyMotion | `<Leader><Leader>w` | Normal | Jump to word start forward |

**Note:** See `:help easymotion` for full list of motions and configuration.

#### vim-visual-multi (mg979/vim-visual-multi)

| Category | Keybinding | Mode | Description |
|----------|------------|------|-------------|
| Multi-Cursor | `<C-Down>` | Normal | Add cursor below |
| Multi-Cursor | `<C-LeftMouse>` | Normal | Add cursor at click position |
| Multi-Cursor | `<C-RightMouse>` | Normal | Add word at click position |
| Multi-Cursor | `<C-Up>` | Normal | Add cursor above |
| Multi-Cursor | `<C-n>` | Normal/Visual | Select word / add cursor to next match |
| Multi-Cursor | `<Esc>` | Multi-cursor | Exit multi-cursor mode |
| Multi-Cursor | `<Tab>` | Multi-cursor | Switch cursor/extend mode |
| Multi-Cursor | `N` | Multi-cursor | Get previous match |
| Multi-Cursor | `Q` | Multi-cursor | Remove current cursor |
| Multi-Cursor | `\\A` | Normal | Select all occurrences of word |
| Multi-Cursor | `\\/` | Normal | Start regex search for multi-cursor |
| Multi-Cursor | `\\\\` | Normal | Add cursor at position |
| Multi-Cursor | `\\c` | Normal/Visual | Case conversion menu |
| Multi-Cursor | `[` | Multi-cursor | Select previous cursor |
| Multi-Cursor | `]` | Multi-cursor | Select next cursor |
| Multi-Cursor | `n` | Multi-cursor | Get next match |
| Multi-Cursor | `q` | Multi-cursor | Skip current and get next |

**Note:** See `:help visual-multi` for full documentation and advanced features.

#### gitsigns.nvim (lewis6991/gitsigns.nvim)

| Category | Keybinding | Mode | Description |
|----------|------------|------|-------------|
| Git | `<leader>hB` | Normal | Blame show full |
| Git | `<leader>hR` | Normal | Reset buffer |
| Git | `<leader>hS` | Normal | Stage buffer |
| Git | `<leader>hb` | Normal | Blame line |
| Git | `<leader>hp` | Normal | Preview hunk inline |
| Git | `<leader>hs` | Normal | Stage hunk |
| Git | `<leader>hu` | Normal | Undo stage hunk |
| Git | `<leader>tb` | Normal | Toggle current line blame |
| Git | `<leader>td` | Normal | Toggle deleted lines |
| Git | `[c` | Normal | Previous git hunk |
| Git | `]c` | Normal | Next git hunk |
| Git | `ih` | Operator/Visual | Select git hunk (text object) |

**Note:** See `:help gitsigns` for full documentation.

#### mini.surround (echasnovski/mini.surround)

| Category | Keybinding | Mode | Description |
|----------|------------|------|-------------|
| Surround | `sa` | Normal/Visual | Add surrounding (e.g., `saiw)` surround word with parens) |
| Surround | `sd` | Normal | Delete surrounding (e.g., `sd"` delete quotes) |
| Surround | `sf` | Normal | Find surrounding (move to right) |
| Surround | `sF` | Normal | Find surrounding (move to left) |
| Surround | `sh` | Normal | Highlight surrounding |
| Surround | `sn` | Normal | Update n_lines config |
| Surround | `sr` | Normal | Replace surrounding (e.g., `sr)"` replace parens with quotes) |

**Note:** See `:help mini.surround` for full documentation and examples.

#### mini.ai (echasnovski/mini.ai)

Enhanced text objects that work with operators (`d`, `c`, `y`, etc.) and visual mode.

| Category | Keybinding | Mode | Description |
|----------|------------|------|-------------|
| Text Objects | `a"` / `i"` | Operator/Visual | Around/inside double quotes |
| Text Objects | `a'` / `i'` | Operator/Visual | Around/inside single quotes |
| Text Objects | `a)` / `i)` / `ab` / `ib` | Operator/Visual | Around/inside () parentheses |
| Text Objects | `a>` / `i>` | Operator/Visual | Around/inside <> angle brackets |
| Text Objects | `a?` / `i?` | Operator/Visual | User-prompted text object |
| Text Objects | `a]` / `i]` | Operator/Visual | Around/inside [] brackets |
| Text Objects | `a`` / `i`` | Operator/Visual | Around/inside backticks |
| Text Objects | `a}` / `i}` / `aB` / `iB` | Operator/Visual | Around/inside {} braces |
| Text Objects | `aa` / `ia` | Operator/Visual | Around/inside argument |
| Text Objects | `af` / `if` | Operator/Visual | Around/inside function call |
| Text Objects | `at` / `it` | Operator/Visual | Around/inside tag (HTML/XML) |

**Note:** See `:help mini.ai` for complete list including default Vim text objects (w, s, p, etc.).

#### NvimTree (nvim-tree/nvim-tree.lua)

Keybindings when NvimTree window is open:

| Category | Keybinding | Mode | Description |
|----------|------------|------|-------------|
| NvimTree | `<C-t>` | Normal | Open file in new tab |
| NvimTree | `<C-v>` | Normal | Open file in vertical split |
| NvimTree | `<C-x>` | Normal | Open file in horizontal split |
| NvimTree | `<CR>` / `o` | Normal | Open file/folder |
| NvimTree | `H` | Normal | Toggle hidden files |
| NvimTree | `I` | Normal | Toggle gitignore files |
| NvimTree | `R` | Normal | Refresh tree |
| NvimTree | `Y` | Normal | Copy relative path |
| NvimTree | `a` | Normal | Create new file/folder |
| NvimTree | `c` | Normal | Copy file/folder |
| NvimTree | `d` | Normal | Delete file/folder |
| NvimTree | `gy` | Normal | Copy absolute path |
| NvimTree | `p` | Normal | Paste file/folder |
| NvimTree | `q` | Normal | Close NvimTree |
| NvimTree | `r` | Normal | Rename file/folder |
| NvimTree | `x` | Normal | Cut file/folder |
| NvimTree | `y` | Normal | Copy filename |

**Note:** See `:help nvim-tree-default-mappings` for complete list.

## Plugins

### Core

- `folke/lazy.nvim` - Plugin manager
- `neovim/nvim-lspconfig` - LSP configuration
- `nvim-treesitter/nvim-treesitter` - Syntax highlighting and parsing
- `nvim-telescope/telescope.nvim` - Fuzzy finder
- `ThePrimeagen/harpoon` - Quick file navigation bookmarks

### LSP & Completion

- `williamboman/mason.nvim` - LSP/tool installer manager
- `williamboman/mason-lspconfig.nvim` - Mason LSP bridge
- `WhoIsSethDaniel/mason-tool-installer.nvim` - Auto-install Mason tools
- `hrsh7th/nvim-cmp` - Completion engine
- `hrsh7th/cmp-nvim-lsp` - LSP completion source
- `hrsh7th/cmp-buffer` - Buffer word completion source
- `hrsh7th/cmp-path` - Path completion source
- `L3MON4D3/LuaSnip` - Snippet engine
- `saadparwaiz1/cmp_luasnip` - LuaSnip completion integration
- `j-hui/fidget.nvim` - LSP progress notifications

### Formatting

- `mhartington/formatter.nvim` - Formatter integration

### UI & Appearance

- `navarasu/onedark.nvim` - OneDark colorscheme
- `akinsho/bufferline.nvim` - Buffer tabs UI
- `nvim-tree/nvim-tree.lua` - File tree explorer
- `nvim-tree/nvim-web-devicons` - File icons
- `echasnovski/mini.nvim` - Mini modules collection (statusline, surround, text objects)
- `folke/which-key.nvim` - Keybinding popup hints

### Git

- `lewis6991/gitsigns.nvim` - Git signs in gutter

### Editing

- `tpope/vim-commentary` - Comment toggling
- `unblevable/quick-scope` - f/F/t/T target highlighting
- `easymotion/vim-easymotion` - Enhanced motion commands
- `mg979/vim-visual-multi` - Multiple cursors
- `folke/todo-comments.nvim` - TODO comment highlighting

### Telescope Extensions

- `nvim-telescope/telescope-fzf-native.nvim` - Native FZF sorter
- `nvim-telescope/telescope-ui-select.nvim` - Telescope UI for vim.ui.select
- `nvim-telescope/telescope-file-browser.nvim` - File browser picker

### AI

- `supermaven-inc/supermaven-nvim` - AI code completion

### Treesitter Extensions

- `nvim-treesitter/nvim-treesitter-textobjects` - Enhanced text objects

## Configuration

### LSP Servers

- `lua_ls` - Lua (enhanced with type hints, vim globals, Neovim API support)
- `ts_ls` - TypeScript/JavaScript (with inlay hints enabled)
- `html` - HTML
- `cssls` - CSS
- `jsonls` - JSON
- `vimls` - Vim script (enhanced with vim runtime indexing)

### Formatters

- `stylua` - Lua code formatter
- `eslint_d` - ESLint daemon for JS/TS
- `prettier` - Multi-language formatter (JS/TS/HTML/CSS/JSON)

### Treesitter Parsers

- Core: `c`, `lua`, `vim`, `vimdoc`, `query`, `bash`
- Documentation: `luadoc`, `markdown`, `markdown_inline`
- Utility: `diff`, `regex`
- Auto-install enabled for additional languages
