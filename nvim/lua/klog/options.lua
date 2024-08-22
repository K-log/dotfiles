-- Misc
vim.opt.clipboard = 'unnamedplus'	-- use system clipboard
vim.opt.completeopt = {'menu', 'menuone', 'noselect'}
vim.opt.mouse = 'a'			-- allow mouse

-- Tab
vim.opt.tabstop = 2			-- number of visual spaces per tab
vim.opt.softtabstop = 2			-- number of spaces in tab when editing
vim.opt.shiftwidth = 2			-- insert 2 spaces on a tab
vim.opt.expandtab = true			-- tabs are converted to spaces


-- UI
vim.opt.number = true			-- show absolute line numbers
vim.opt.relativenumber = true		-- show relative number on line around the current line
vim.opt.cursorline = true		-- highline the line underneath the cursor
vim.opt.splitbelow = true		-- open new vertical splits below
vim.opt.splitright = true		-- open new horizontal splits right
vim.opt.showmode = true			-- show the current editing mode (cause we forget)


-- Searching
vim.opt.incsearch = true		-- search as characters are entered
vim.opt.hlsearch = true			-- highlight search matches
vim.opt.ignorecase = true		-- ignore case in searches
vim.opt.smartcase = true		-- search case sensitive if an upper case charater is entered
