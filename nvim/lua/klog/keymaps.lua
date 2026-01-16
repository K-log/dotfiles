vim.g.mapleader = " " -- Make sure to set `mapleader` before lazy so your mappings are correct
vim.g.maplocalleader = " " -- Same for `maplocalleader`

vim.keymap.set("i", "jk", "<Esc>")
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

vim.keymap.set("n", "<C-S-l>", vim.cmd.bnext, { desc = "Next buffer" })
vim.keymap.set("n", "<C-S-h>", vim.cmd.bprev, { desc = "Previous buffer" })
vim.keymap.set("n", "<C-S-q>", vim.cmd.bdelete, { desc = "Close current buffer" })

vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
vim.keymap.set("n", "<leader>gg", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.goto_next, { desc = "Jump to next diagnostic [e]rror" })
vim.keymap.set("n", "<leader>E", vim.diagnostic.goto_prev, { desc = "Jump to prev diagnostic [E]rror" })
vim.keymap.set("n", "<leader>fe", vim.cmd.Ex, { desc = "[F]iles [E]xplore" })
vim.keymap.set("n", "<leader>fn", vim.cmd.enew, { desc = "[F]ile [N]ew" })
vim.keymap.set("n", "<leader>cp", vim.cmd.Format, { desc = "[C]ode [P]retty (format)" })

-- Additional mappings for IdeaVim parity
-- ESLint fix (formatter already sets eslint_d; provide explicit mapping)
vim.keymap.set("n", "<leader>cl", function()
	vim.cmd("Format")
end, { desc = "[C]ode [L]int fix" })

-- Optimize imports (TS/JS via LSP organize imports)
vim.keymap.set("n", "<leader>ci", function()
	local params = {
		command = "_typescript.organizeImports",
		arguments = { vim.api.nvim_buf_get_name(0) },
	}
	vim.lsp.buf.execute_command(params)
end, { desc = "[C]ode optimize [I]mports" })

-- Code actions & rename
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "[C]ode [A]ctions" })
vim.keymap.set("n", "<leader>cre", vim.lsp.buf.rename, { desc = "[C]ode [R]ename [E]lement" })

-- Rename file helper
vim.keymap.set("n", "<leader>crf", function()
	local old = vim.api.nvim_buf_get_name(0)
	local new = vim.fn.input("Rename file: ", old, "file")
	if new == nil or new == "" or new == old then
		return
	end
	vim.cmd(string.format("saveas %s", vim.fn.fnameescape(new)))
	os.remove(old)
	vim.cmd("bdelete #")
end, { desc = "[C]ode [R]ename [F]ile" })

-- Window management (splits)
vim.keymap.set("n", "<leader>wh", "<C-w>s", { desc = "[W]indow split [H]orizontally" })
vim.keymap.set("n", "<leader>wv", "<C-w>v", { desc = "[W]indow split [V]ertically" })
vim.keymap.set("n", "<leader>wu", function()
	vim.cmd("only")
end, { desc = "[W]indow [U]nsplit" })
vim.keymap.set("n", "<leader>wm", function()
	-- Move current window to a new tab (approximate MoveEditorToOppositeTabGroup)
	vim.cmd("tab split")
end, { desc = "[W]indow [M]ove to tab" })
vim.keymap.set("n", "<leader>we", function()
	-- Maximize current window (toggle) using built-in option
	vim.cmd("wincmd _ | wincmd |")
end, { desc = "[W]indow [E]xpand" })
vim.keymap.set("n", "<leader>wq", "<cmd>close<CR>", { desc = "[W]indow [Q]uit" })

-- Method navigation (requires treesitter symbols fallback)
vim.keymap.set("n", "]]", function()
	vim.cmd([[normal! ]m]])
end, { desc = "Next method (approximate)" })
vim.keymap.set("n", "[[", function()
	vim.cmd([[normal! [m]])
end, { desc = "Prev method (approximate)" })

-- Move line up/down like Shift+J / Shift+K Idea actions
vim.keymap.set("n", "<S-J>", ":m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<S-K>", ":m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set("v", "<S-J>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "<S-K>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Harpoon toggle (bookmark list via Telescope from harpoon config) - integrate mapping alias
vim.keymap.set("n", "<leader>ht", function()
	vim.api.nvim_input("<C-e>")
end, { desc = "[H]arpoon [T]oggle" })

-- Search recent files (Telescope oldfiles already mapped to <leader>s.)
-- Additional alias for Idea parity: <leader>s. already defined in telescope config
