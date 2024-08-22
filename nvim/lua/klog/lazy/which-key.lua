return {
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 300
		end,
		config = function()
			local wk = require("which-key")
			wk.setup()

			wk.register({
				{ "<leader>f", group = "File" },
				{ "<leader>ff", desc = "Find File" },
				{ "<leader>fn", desc = "New File" },
				{ "<leader>k", group = "Formatter" },
				{ "<leader>kf", desc = "Format File" },
				{ "<leader>p", group = "Project" },
				{ "<leader>pf", desc = "Explorer" },
			})
		end,
	},
}
