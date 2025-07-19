local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.o.number = true
vim.o.relativenumber = true
vim.o.mouse = "a"
vim.o.showmode = false
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = "yes"
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.inccommand = "split"
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.confirm = true

require("lazy").setup({
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		keys = {
			{
				"<leader>?",
				function()
					require("which-key").show({ global = false })
				end,
				desc = "Buffer Local Keymaps (which-key)",
			},
		},
		opts = {
			delay = 500,
		},
	},
	{
		"navarasu/onedark.nvim",
		priority = 1000,
		config = function()
			require("onedark").setup({
				style = "darker",
			})

			require("onedark").load()
		end,
	},
	{
		"lewis6991/gitsigns.nvim",
		opts = {},
		config = function()
			local gs = require("gitsigns")

			local map = function(keys, func, desc)
				vim.keymap.set("n", keys, func, { desc = "GIT hunk: " .. desc })
			end

			map("<leader>gr", gs.reset_hunk, "Reset")
			map("<leader>gs", gs.stage_hunk, "Stage")
			map("<leader>gd", gs.preview_hunk, "Diff")
		end,
	},
	{
		"stevearc/oil.nvim",
		opts = {
			view_options = {
				show_hidden = true,
			},
		},
		dependencies = {
			{ "echasnovski/mini.icons", opts = {} },
		},
		lazy = false,
	},
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = true,
		opts = {
			disable_filetype = {},
		},
	},
	{
		"nvim-telescope/telescope.nvim",
		event = "VimEnter",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
				cond = function()
					return vim.fn.executable("make") == 1
				end,
			},
			{ "nvim-telescope/telescope-ui-select.nvim" },
		},
		config = function()
			local ts = require("telescope")
			ts.setup({
				defaults = {
					-- It's not possible to set a default theme yet
					-- See: https://github.com/nvim-telescope/telescope.nvim/issues/848
					-- theme = "ivy"
					mappings = {
						i = {
							["<Esc>"] = "close",
						},
					},
				},
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown(),
					},
				},
				pickers = {
					help_tags = { theme = "ivy" },
					keymaps = { theme = "ivy" },
					current_buffer_fuzzy_find = { theme = "ivy" },
					find_files = { theme = "ivy" },
					live_grep = { theme = "ivy" },
					treesitter = { theme = "ivy" },
					diagnostics = { theme = "ivy" },
					buffers = { theme = "ivy" },
					git_files = { theme = "ivy" },
					jumplist = { theme = "ivy" },
					lsp_document_symbols = { theme = "ivy" },
					lsp_dynamic_workspace_symbols = { theme = "ivy" },
					lsp_references = { theme = "ivy" },
					lsp_implementations = { theme = "ivy" },
					lsp_definitions = { theme = "ivy" },
					lsp_type_definitions = { theme = "ivy" },
				},
			})

			ts.load_extension("fzf")
			ts.load_extension("ui-select")

			local b = require("telescope.builtin")
			vim.keymap.set("n", "<leader>h", b.help_tags, { desc = "Find help tags" })
			vim.keymap.set("n", "<leader>k", b.keymaps, { desc = "Find keymaps" })
			vim.keymap.set("n", "<leader>/", b.current_buffer_fuzzy_find, { desc = "Find in current buffer" })
			vim.keymap.set("n", "<leader>f", b.find_files, { desc = "Find files" })
			vim.keymap.set("n", "<leader>c", b.commands, { desc = "Find commands" })
			vim.keymap.set("n", "<leader>w", b.live_grep, { desc = "Find word" })
			vim.keymap.set("n", "<leader>d", b.diagnostics, { desc = "Find diagnostics" })
			vim.keymap.set("n", "<leader>b", b.buffers, { desc = "Find open buffers" })
			vim.keymap.set("n", "<leader>m", b.marks, { desc = "Find marks" })
			vim.keymap.set("n", "<leader>j", b.jumplist, { desc = "Find in jump list" })
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		main = "nvim-treesitter.configs",
		opts = {
			ensure_installed = {
				"lua",
				"go",
				"gotmpl",
				"rust",
				"zig",
				"bash",
				"c",
				"cpp",
				"html",
				"css",
				"javascript",
				"typescript",
				"vue",
				"json",
				"jsonc",
				"markdown",
				"markdown_inline",
				"query",
				"toml",
				"asm",
				"awk",
				"make",
				"diff",
			},
		},
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{ "j-hui/fidget.nvim", opts = {} },
		},
		config = function()
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("OnLspAttach", { clear = true }),
				callback = function(event)
					vim.o.completeopt = "menu,menuone,noinsert"

					local client = assert(vim.lsp.get_client_by_id(event.data.client_id))
					vim.lsp.completion.enable(true, client.id, event.buf, { autotrigger = false })

					vim.keymap.set("i", "<c-space>", function()
						vim.lsp.completion.get()
					end)

					local map = function(keys, func, desc)
						vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end

					local ts = require("telescope.builtin")
					map("<leader>s", ts.lsp_document_symbols, "Find symbols")
					map("<leader>S", ts.lsp_dynamic_workspace_symbols, "Find workspace symbols")
					map("<leader>r", vim.lsp.buf.rename, "Rename")
					map("<leader>a", vim.lsp.buf.code_action, "Code action")
					map("gr", ts.lsp_references, "Go to references")
					map("gm", ts.lsp_implementations, "Go to implementation")
					map("gd", ts.lsp_definitions, "Go to definition")
					map("gD", vim.lsp.buf.declaration, "Go to declaration")
					map("gy", ts.lsp_type_definitions, "Go to type definition")
				end,
			})

			local lspconfig = require("lspconfig")

			lspconfig.clangd.setup({})

			lspconfig.lua_ls.setup({
				settings = {
					Lua = {
						completion = {
							callSnippet = "Replace",
						},
						diagnostics = { disable = { "missing-fields" } },
					},
				},
			})

			lspconfig.gopls.setup({})

			local node_modules_global = "/usr/local/bin/node_modules"

			local nvm_bin = os.getenv("NVM_BIN")
			if nvm_bin ~= nil then
				node_modules_global = nvm_bin .. "/../lib/node_modules"
			end

			lspconfig.ts_ls.setup({
				init_options = {
					plugins = {
						{
							name = "@vue/typescript-plugin",
							location = node_modules_global .. "/@vue/language-server",
							languages = { "vue" },
						},
					},
				},
				filetypes = {
					"javascript",
					"javascriptreact",
					"javascript.jsx",
					"typescript",
					"typescriptreact",
					"typescript.tsx",
					"vue",
				},
			})

			lspconfig.zls.setup({})

			lspconfig.ts_ls.setup({})
		end,
	},
	{
		"stevearc/conform.nvim",
		opts = {},
		config = function()
			local conform = require("conform")
			conform.setup({
				formatters_by_ft = {
					lua = { "stylua" },
					go = { "goimports", "gofumpt" },
					typescript = { "prettierd", "prettier", stop_at_first = true },
					zig = { "zigfmt" },
				},
			})

			vim.keymap.set({ "n", "v" }, "<leader>i", function()
				conform.format({ async = true })
			end, { desc = "Format code" })
		end,
	},
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		opts = {},
	},
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		opts = {},
		keys = {
			{
				"s",
				mode = { "n", "x", "o" },
				function()
					require("flash").jump()
				end,
				desc = "Flash",
			},
		},
	},
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},
	"mfussenegger/nvim-dap",
	{ dir = "~/.config/nvim/plugins/dapconfig" },
})

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

vim.keymap.set("n", "U", "<C-r>", { noremap = true })
-- not working for some reason
-- vim.keymap.set("n", "<leader>d", "<C-W>d", { desc = "Show diagnostics under the cursor", noremap = true })
