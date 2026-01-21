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
					avoid = {
						"NvimTree",
					},
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
							-- Enable more diagnostics for better type checking
							neededFileStatus = {
								["codestyle-check"] = "Any",
							},
						},
						workspace = {
							library = vim.api.nvim_get_runtime_file("", true),
							checkThirdParty = false,
						},
						completion = {
							callSnippet = "Replace",
							showWord = "Disable", -- Don't show words from buffer
						},
						telemetry = { enable = false },
						format = { enable = false }, -- We use stylua via formatter.nvim
						hint = {
							enable = true, -- Enable inline type hints
							setType = true, -- Show type hints for variables
							paramName = "All", -- Show parameter names in function calls
							paramType = true, -- Show parameter types
							arrayIndex = true, -- Don't show array indices (too noisy)
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
					javascript = {
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
			vimls = {
				settings = {
					vim = {
						iskeyword = "@,48-57,_,192-255,-#",
						vimruntime = vim.env.VIMRUNTIME,
						runtimepath = vim.o.runtimepath,
						diagnostic = { enable = true },
						indexes = {
							runtimepath = true,
							gap = 100,
							count = 8,
						},
						suggest = {
							fromRuntimepath = true,
							fromVimruntime = true,
						},
					},
				},
			},
		}

		-- Ensure servers are installed
		local ensure_installed = vim.tbl_keys(servers)
		table.insert(ensure_installed, "stylua") -- Ensure stylua formatter is installed
		require("mason-tool-installer").setup({
			ensure_installed = ensure_installed,
		})

		-- Setup LSP servers
		require("mason-lspconfig").setup({
			handlers = {
				function(server_name)
					local server = servers[server_name] or {}
					server.capabilities = vim.tbl_deep_extend("force", {}, lsp_capabilities, server.capabilities or {})
					vim.lsp.config(server_name, server)
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
				{ name = "nvim_lsp" },
				{ name = "luasnip" },
				{ name = "supermaven" },
			}, {
				{ name = "buffer" },
			}),
		})

		-- Diagnostics configuration
		vim.diagnostic.config({
			float = {
				focusable = false,
				style = "minimal",
				border = "rounded",
				source = "if_many",
				header = "",
				prefix = "",
			},
		})

		-- LSP attach autocmd
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
			callback = function(event)
				-- Document highlight
				local client = vim.lsp.get_client_by_id(event.data.client_id)
				if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
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

				-- Inlay hints toggle
				if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
					vim.keymap.set("n", "<leader>ch", function()
						vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
					end, { buffer = event.buf, desc = "[C]ode Inlay [H]ints" })
				end

				-- Standard LSP keymaps
				vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = event.buf, desc = "Hover Documentation" })
				vim.keymap.set(
					"n",
					"<leader>cd",
					vim.lsp.buf.type_definition,
					{ buffer = event.buf, desc = "[C]ode Type [D]efinition" }
				)
				vim.keymap.set(
					"n",
					"<leader>cs",
					vim.lsp.buf.signature_help,
					{ buffer = event.buf, desc = "[C]ode [S]ignature help" }
				)
				-- Signature help in insert mode while typing function parameters
				vim.keymap.set(
					"i",
					"<C-h>",
					vim.lsp.buf.signature_help,
					{ buffer = event.buf, desc = "Signature help" }
				)
			end,
		})
	end,
}
