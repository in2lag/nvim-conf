vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.pack.add({
	{ src = "https://github.com/romus204/tree-sitter-manager.nvim" },
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/catppuccin/nvim" },
	{ src = "https://github.com/nvim-tree/nvim-tree.lua" },
	{ src = "https://github.com/nvim-tree/nvim-web-devicons" },
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/nvim-telescope/telescope.nvim" },
	{ src = "https://github.com/lewis6991/gitsigns.nvim" },
	{ src = "https://github.com/sindrets/diffview.nvim" },
	{ src = "https://github.com/folke/which-key.nvim" },
	{ src = "https://github.com/stevearc/conform.nvim" },
	{ src = "https://github.com/Saghen/blink.cmp", version = vim.version.range("1.*") },
	{ src = "https://github.com/zbirenbaum/copilot.lua" },
	{ src = "https://github.com/rmagatti/auto-session" },
	{ src = "https://github.com/rmagatti/goto-preview" },
	{ src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" },
	{ src = "https://github.com/HiPhish/rainbow-delimiters.nvim" },
	{ src = "https://github.com/nvim-mini/mini.nvim" },
	{ src = "https://github.com/sphamba/smear-cursor.nvim" },
	{ src = "https://github.com/mfussenegger/nvim-dap" },
	{ src = "https://github.com/nvim-neotest/nvim-nio" },
	{ src = "https://github.com/rcarriga/nvim-dap-ui" },
	{ src = "https://github.com/theHamsta/nvim-dap-virtual-text" },
	{ src = "https://github.com/leoluz/nvim-dap-go" },
})

if vim.loader then
	vim.loader.enable()
end

require("core.options")
require("core.keymaps")
require("core.treesitter")
require("core.lsp")
require("ui.git")
require("ui.search")
require("ui.session")
require("ui.tree")
require("ui.numbers")
require("ui.cursorline")
require("ui.whichkey")
require("ui.format")
require("ui.completion")
require("ui.peek")
require("ui.diagnostics")
require("ui.statusline")
require("ui.surround")
require("ui.pairs")
require("ui.indent")
require("ui.smear")
require("ui.markdown")
require("debug.dap")
require("ai.copilot")
require("catppuccin").setup({ flavour = "frappe" })

vim.cmd.colorscheme("catppuccin-frappe")
