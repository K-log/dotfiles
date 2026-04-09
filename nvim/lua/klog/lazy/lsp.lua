return {
	"neovim/nvim-lspconfig",
	dependencies = {
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-path",
		"hrsh7th/nvim-cmp",
		"L3MON4D3/LuaSnip",
		"saadparwaiz1/cmp_luasnip",
		"j-hui/fidget.nvim",
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

		require("fidget").setup({
			notification = {
				window = {
					avoid = { "NvimTree" },
				},
			},
		})

		require("mason").setup()

		-- Server configurations
		local servers = {
			lua_ls = {
				settings = {
					Lua = {
						runtime = { version = "LuaJIT" },
						diagnostics = {
							globals = { "vim" },
							neededFileStatus = { ["codestyle-check"] = "Any" },
						},
						workspace = {
							library = vim.api.nvim_get_runtime_file("", true),
							checkThirdParty = false,
						},
						completion = {
							callSnippet = "Replace",
							showWord = "Disable",
						},
						telemetry = { enable = false },
						format = { enable = false },
						hint = {
							enable = true,
							setType = true,
							paramName = "All",
							paramType = true,
							arrayIndex = true,
						},
					},
				},
			},

			ts_ls = {
				settings = {
					typescript = {
						inlayHints = {
							includeInlayParameterNameHints = "all",
							includeInlayFunctionParameterTypeHints = true,
							includeInlayVariableTypeHints = true,
							includeInlayPropertyDeclarationTypeHints = true,
							includeInlayFunctionLikeReturnTypeHints = true,
						},
					},
				},
			},
			html = {},
			cssls = {},
			jsonls = {},
		}

		-- Ensure servers are installed
		local ensure_installed = vim.tbl_keys(servers)
		table.insert(ensure_installed, "stylua")
		require("mason-tool-installer").setup({
			ensure_installed = ensure_installed,
		})

		-- Setup LSP servers using Neovim 0.12 native API
		require("mason-lspconfig").setup({
			handlers = {
				function(server_name)
					local server_opts = servers[server_name] or {}
					server_opts.capabilities =
						vim.tbl_deep_extend("force", {}, lsp_capabilities, server_opts.capabilities or {})

					-- 1. Use the new native config registration
					vim.lsp.config(server_name, server_opts)

					-- 2. Explicitly enable the server for the current session
					vim.lsp.enable(server_name)
				end,
			},
		})

		-- Completion setup
		cmp.setup({
			snippet = {
				expand = function(args)
					require("luasnip").lsp_expand(args.body)
				end,
			},
			mapping = cmp.mapping.preset.insert({
				["<C-j>"] = cmp.mapping.select_prev_item(),
				["<C-k>"] = cmp.mapping.select_next_item(),
				["<Enter>"] = cmp.mapping.confirm({ select = true }),
				["<C-Space>"] = cmp.mapping.complete(),
			}),
			sources = cmp.config.sources({
				{ name = "nvim_lsp", priority = 1000 },
				{ name = "luasnip", priority = 750 },
			}, {
				{ name = "buffer" },
			}),
		})

		-- Standardized 0.12 LSP Attach
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
			callback = function(event)
				local client = vim.lsp.get_client_by_id(event.data.client_id)
				local methods = vim.lsp.protocol.Methods -- Using 0.12 Methods table

        if not client then return end

				-- Document highlight
				if client:supports_method(methods.textDocument_documentHighlight) then
					local highlight_group = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })
					vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
						buffer = event.buf,
						group = highlight_group,
						callback = vim.lsp.buf.document_highlight,
					})
					vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
						buffer = event.buf,
						group = highlight_group,
						callback = vim.lsp.buf.clear_references,
					})
				end

				-- Inlay hints toggle using 0.12 syntax
				if client:supports_method(methods.textDocument_inlayHint) then
					vim.keymap.set("n", "<leader>ch", function()
						vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
					end, { buffer = event.buf, desc = "Toggle Inlay Hints" })
				end

				-- Keymaps
				local opts = { buffer = event.buf }
				vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
				vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
				vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
			end,
		})
	end,
}
