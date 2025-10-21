return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	opts = {
		ensure_installed = {
			"vim",
			"vimdoc",
			"javascript",
			"typescript",
			"bash",
			"html",
			"diff",
			"lua",
			"luadpc",
			"markdown",
			"markdown_inline",
			"query",
		},
		auto_install = true,
		highlight = {
			enable = true,

			-- add langs here if weird handling of indenting
			additional_vim_regex_highlighting = {},
		},
		indent = { enable = true, disable = {} },
		textobjects = {
			select = {
				enable = true,
				lookahead = true,
				keymaps = {
					["aa"] = "@parameter.outer",
					["ia"] = "@parameter.inner",
				},
			},
		},
	},
  { -- Treesitter textobjects (argument/parameter objects similar to argtextobj)
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    lazy = true,
  },
}
