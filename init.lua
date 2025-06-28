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

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

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
	"lewis6991/gitsigns.nvim",
	{
		"stevearc/oil.nvim",
		opts = {},
		dependencies = {
			{ "echasnovski/mini.icons", opts = {} },
		},
		lazy = false,
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
				},
			})

			ts.load_extension("fzf")
			ts.load_extension("ui-select")

			local b = require("telescope.builtin")
			vim.keymap.set("n", "<leader>h", b.help_tags, { desc = "Find help" })
			vim.keymap.set("n", "<leader>k", b.keymaps, { desc = "Find keymap" })
			vim.keymap.set("n", "<leader>/", b.current_buffer_fuzzy_find, { desc = "Find in current buffer" })
			vim.keymap.set("n", "<leader>f", b.find_files, { desc = "Find files" })
			-- vim.keymap.set("n", "<leader>s", builtin.builtin, { desc = "Find builtin" })
			vim.keymap.set("n", "<leader>w", b.live_grep, { desc = "Find word" })
			vim.keymap.set("n", "<leader>d", b.diagnostics, { desc = "Find diagnostic" })
			vim.keymap.set("n", "<leader>b", b.buffers, { desc = "Find open buffer" })
			vim.keymap.set("n", "<leader>g", b.git_files, { desc = "Find Git files" })
			vim.keymap.set("n", "<leader>j", b.jumplist, { desc = "Find in jump list" })
			-- vim.keymap.set("n", "<leader>r", builtin.resume, { desc = "Resume last find" })
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
				"rust",
				"zig",
				"bash",
				"c",
				"cpp",
				"diff",
				"html",
				"markdown",
				"markdown_inline",
				"query",
				"javascript",
				"typescript",
				"json",
				"jsonc",
				"toml",
				"asm",
				"awk",
				"css",
				"gotmpl",
				"make",
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
					vim.o.completeopt = "menu,menuone,noinsert,preview"

					local client = assert(vim.lsp.get_client_by_id(event.data.client_id))
					vim.lsp.completion.enable(true, client.id, event.buf, { autotrigger = false })

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
			lspconfig.gopls.setup({})
		end,
	},
	{
		"stevearc/conform.nvim",
		opts = {},
		config = function()
			require("conform").setup({
				formatters_by_ft = {
					lua = { "stylua" },
					go = { "goimports", "gofumpt" },
				},
				format_on_save = {
					lsp_format = "fallback",
					timeout_ms = 500,
				},
			})
		end,
	},
})
