return {
	{
		"mhartington/formatter.nvim",
		config = function()
			local util = require("formatter.util")
			local formatter = require("formatter")

			formatter.setup({
				-- Enable or disable logging
				logging = true,
				-- Set the log level
				log_level = vim.log.levels.INFO,
				-- All formatter configurations are opt-in
				filetype = {
					-- Formatter configurations for filetype "lua" go here
					-- and will be executed in order
					lua = {
						-- "formatter.filetypes.lua" defines default configurations for the
						-- "lua" filetype
						require("formatter.filetypes.lua").stylua,

						-- You can also define your own configuration
						function()
							-- Supports conditional formatting
							if util.get_current_buffer_file_name() == "special.lua" then
								return nil
							end

							-- Full specification of configurations is down below and in Vim help
							-- files
							return {
								exe = "stylua",
								args = {
									"--search-parent-directories",
									"--stdin-filepath",
									util.escape_path(util.get_current_buffer_file_path()),
									"--",
									"-",
								},
								stdin = true,
							}
						end,
					},

					javascript = {
						require("formatter.filetypes.javascript").prettier,
						require("formatter.filetypes.javascript").eslint,
					},
					typescript = {
						require("formatter.filetypes.typescript").prettier,
						require("formatter.filetypes.typescript").eslint,
					},
					javascriptreact = {
						require("formatter.filetypes.javascriptreact").prettier,
						require("formatter.filetypes.javascriptreact").eslint,
					},
					typescriptreact = {
						require("formatter.filetypes.typescriptreact").prettier,
						require("formatter.filetypes.typescriptreact").eslint,
					},
					json = {
						require("formatter.filetypes.json").prettier,
					},
					-- Use the special "*" filetype for defining formatter configurations on
					-- any filetype
					["*"] = {
						-- "formatter.filetypes.any" defines default configurations for any
						-- filetype
						require("formatter.filetypes.any").remove_trailing_whitespace,
					},
				},
			})
		end,
	},
}
