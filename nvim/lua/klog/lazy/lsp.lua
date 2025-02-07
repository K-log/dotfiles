return {
	"neovim/nvim-lspconfig",
	dependencies = {
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-path",
		"hrsh7th/cmp-cmdline",
		"hrsh7th/nvim-cmp",
		"L3MON4D3/LuaSnip",
		"saadparwaiz1/cmp_luasnip",
		"j-hui/fidget.nvim",
		"mhartington/formatter.nvim",
	},

	config = function()
		local cmp = require("cmp")
		local cmp_lsp = require("cmp_nvim_lsp")
		local lsp_capabilities = vim.tbl_deep_extend(
			"force",
			{},
			vim.lsp.protocol.make_client_capabilities(),
			cmp_lsp.default_capabilities()
		)
		require("fidget").setup()
		require("mason").setup()

		local servers = {
			-- clangd = {},
			-- gopls = {},
			-- pyright = {},
			-- rust_analyzer = {},
			-- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
			--
			-- Some languages (like typescript) have entire language plugins that can be useful:
			--    https://github.com/pmizio/typescript-tools.nvim
			--
			-- But for many setups, the LSP (`ts_ls`) will work just fine
			ts_ls = {},
			--

			lua_ls = {
				-- cmd = { ... },
				-- filetypes = { ... },
				-- capabilities = {},
				settings = {
					Lua = {
						completion = {
							callSnippet = "Replace",
						},
						-- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
						-- diagnostics = { disable = { 'missing-fields' } },
					},
				},
			},
		}

		local ensure_installed = vim.tbl_keys(servers or {})
		vim.list_extend(ensure_installed, {
			"stylua", -- Used to format Lua code
			"prettier",
			"eslint_d",
		})

		require("mason-lspconfig").setup({
			handlers = {
				function(server_name) -- default handler (optional)
					local server = servers[server_name] or {}
					server.capabilities = vim.tbl_deep_extend("force", {}, lsp_capabilities, server.capabilities or {})
					require("lspconfig")[server_name].setup(server)
				end,

				["lua_ls"] = function()
					local lspconfig = require("lspconfig")
					lspconfig.lua_ls.setup({
						capabilities = lsp_capabilities,
						settings = {
							Lua = {
								runtime = { version = "LuaJIT" },
								diagnostics = {
									globals = { "vim", "it", "describe", "before_each", "after_each" },
								},
							},
						},
					})
				end,
			},
		})

		local cmp_select = { behavior = cmp.SelectBehavior.Select }

		cmp.setup({
			snippet = {
				expand = function(args)
					require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
				end,
			},
			mapping = cmp.mapping.preset.insert({
				["<C-j>"] = cmp.mapping.select_prev_item(cmp_select),
				["<C-k>"] = cmp.mapping.select_next_item(cmp_select),
				["<Enter>"] = cmp.mapping.confirm({ select = true }),
				["<C-Space>"] = cmp.mapping.complete(),
			}),
			sources = cmp.config.sources({
				{ name = "nvim_lsp" },
				{ name = "luasnip" }, -- For luasnip users.
			}, {
				{ name = "buffer" },
			}),
		})

		vim.diagnostic.config({
			-- update_in_insert = true,
			float = {
				focusable = false,
				style = "minimal",
				border = "rounded",
				source = "always",
				header = "",
				prefix = "",
			},
		})

		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
			callback = function(event)

				vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, { buffer = event.buf, desc = "[C]ode [R]ename" })
				vim.keymap.set(
					{ "n", "x" },
					"<leader>ca",
					vim.lsp.buf.code_action,
					{ buffer = event.buf, desc = "[C]ode [A]ction" }
				)

				-- The following two autocommands are used to highlight references of the
				-- word under your cursor when your cursor rests there for a little while.
				--    See `:help CursorHold` for information about when this is executed
				--
				-- When you move your cursor, the highlights will be cleared (the second autocommand).
				local client = vim.lsp.get_client_by_id(event.data.client_id)
				if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
					local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
					vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
						buffer = event.buf,
						group = highlight_augroup,
						callback = vim.lsp.buf.document_highlight,
					})

					vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
						buffer = event.buf,
						group = highlight_augroup,
						callback = vim.lsp.buf.clear_references,
					})

					vim.api.nvim_create_autocmd("LspDetach", {
						group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
						callback = function(event2)
							vim.lsp.buf.clear_references()
							vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
						end,
					})
				end

				-- The following code creates a keymap to toggle inlay hints in your
				-- code, if the language server you are using supports them
				--
				-- This may be unwanted, since they displace some of your code
				if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
          vim.keymap.set("n", "<leader>ch", function()
						vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
					end, { buffer=event.buf, desc = "Toggle [C]ode Inlay [H]ints"})
				end
			end,
		})
	end,
}
