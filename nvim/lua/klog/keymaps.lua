vim.g.mapleader = " " -- Make sure to set `mapleader` before lazy so your mappings are correct
vim.g.maplocalleader = " " -- Same for `maplocalleader`

vim.keymap.set("i", "jk", "<esc>")
vim.keymap.set("n", "<leader>pf", vim.cmd.Ex)
vim.keymap.set("n", "<leader>fn", vim.cmd.enew)
vim.keymap.set("n", "<leader>kf", vim.cmd.Format)
