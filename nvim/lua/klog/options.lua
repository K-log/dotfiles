-- Tab
vim.opt.tabstop = 2 -- number of visual spaces per tab
vim.opt.softtabstop = 2 -- number of spaces in tab when editing
vim.opt.shiftwidth = 2 -- insert 2 spaces on a tab
vim.opt.expandtab = true -- tabs are converted to spaces

-- UI
vim.opt.number = true -- show absolute line numbers
vim.opt.relativenumber = true -- show relative number on line around the current line
vim.opt.cursorline = true -- highline the line underneath the cursor
vim.opt.splitbelow = true -- open new vertical splits below
vim.opt.splitright = true -- open new horizontal splits right
vim.opt.showmode = true -- show the current editing mode (cause we forget)
vim.opt.signcolumn = "yes" -- always display the sign column
vim.opt.splitright = true -- always vsplit right
vim.opt.splitbelow = true -- always hsplit below
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.inccommand = 'split' -- preview substitution live on type
vim.opt.scrolloff = 10


-- Searching
vim.opt.incsearch = true -- search as characters are entered
vim.opt.hlsearch = true -- highlight search matches
vim.opt.ignorecase = true -- ignore case in searches
vim.opt.smartcase = true -- search case sensitive if an upper case charater is entered

-- Misc
vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.mouse = "a" -- allow mouse
vim.g.have_nerd_font = true -- have nerd fonts installed and selected in terminal
vim.schedule(function()
	-- Sync keyboard with OS after UiEnter to speed up startup time
	vim.opt.clipboard = "unnamedplus"
end)
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})
