vim.g.mapleader = " " -- Make sure to set `mapleader` before lazy so your mappings are correct
vim.g.maplocalleader = " " -- Same for `maplocalleader`

vim.keymap.set("i", "jk", "<Esc>")
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.goto_next, { desc = "Jump to next diagnostic [e]rror" })
vim.keymap.set("n", "<leader>E", vim.diagnostic.goto_prev, { desc = "Jump to prev diagnostic [E]rror" })
vim.keymap.set("n", "<leader>fe", vim.cmd.Ex, { desc = "[F]iles [E]xplore" })
vim.keymap.set("n", "<leader>fn", vim.cmd.enew, { desc = "[F]ile [N]ew" })
vim.keymap.set("n", "<leader>cp", vim.cmd.Format, { desc = "[C]ode [P]retty" })
