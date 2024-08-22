return {
	{
		"navarasu/onedark.nvim",
		config = function()
			require("onedark").setup({
				style = "deep",
				transparent = false,
			})
			require("onedark").load()
		end,
	},
}
