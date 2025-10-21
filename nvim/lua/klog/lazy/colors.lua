return {
	{
		"navarasu/onedark.nvim",
		config = function()
			require("onedark").setup({
				style = "cool",
				transparent = false,
			})
			require("onedark").load()
		end,
	},
}
