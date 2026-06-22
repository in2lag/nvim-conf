vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Plugins pinned to exact commits. To bump one: change its `version` here,
-- :restart, then `:lua vim.pack.update({ '<name>' })` and confirm with :write.
vim.pack.add({
	{ src = "https://github.com/romus204/tree-sitter-manager.nvim", version = "33a94d022e3a5a500d878b784ba7fec61559c70a" },
	{ src = "https://github.com/neovim/nvim-lspconfig", version = "81878de76c0de4ce289513734ad80c31ec7871b8" },
	{ src = "https://github.com/catppuccin/nvim", version = "426dbebe06b5c69fd846ceb17b42e12f890aedf1" },
	{ src = "https://github.com/nvim-tree/nvim-tree.lua", version = "d277467fc0d1d0e2bca88165a1de6b526f9f6fe8" },
	{ src = "https://github.com/nvim-tree/nvim-web-devicons", version = "c72328a5494b4502947a022fe69c0c47e53b6aa6" },
	{ src = "https://github.com/nvim-lua/plenary.nvim", version = "74b06c6c75e4eeb3108ec01852001636d85a932b" },
	{ src = "https://github.com/nvim-telescope/telescope.nvim", version = "506338434fec5ad19cb1f8d45bf92d66c4917393" },
	{ src = "https://github.com/lewis6991/gitsigns.nvim", version = "6d808f99bd63303646794406e270bd553ad7792e" },
	{ src = "https://github.com/sindrets/diffview.nvim", version = "4516612fe98ff56ae0415a259ff6361a89419b0a" },
	{ src = "https://github.com/folke/which-key.nvim", version = "3aab2147e74890957785941f0c1ad87d0a44c15a" },
	{ src = "https://github.com/stevearc/conform.nvim", version = "dca1a190aa85f9065979ef35802fb77131911106" },
	{ src = "https://github.com/Saghen/blink.cmp", version = "78336bc89ee5365633bcf754d93df01678b5c08f" },
	{ src = "https://github.com/zbirenbaum/copilot.lua", version = "3b95c93d804077dd409d62a6da53a8c92ac8f415" },
	{ src = "https://github.com/rmagatti/auto-session", version = "62437532b38495551410b3f377bcf4aaac574ebe" },
	{ src = "https://github.com/rmagatti/goto-preview", version = "d2d6923c9b9e0e43f0b9b566f261a8b1ae016540" },
	{ src = "https://github.com/MeanderingProgrammer/render-markdown.nvim", version = "3f3eea97b80839f629c951ca660ffd125bfa5b34" },
	{ src = "https://github.com/HiPhish/rainbow-delimiters.nvim", version = "a798325b7f36acc62741d1029930a7b96d4dd4bf" },
	{ src = "https://github.com/nvim-mini/mini.nvim", version = "1345d191bb3da9c7b0e977f4387c5761f9bff68d" }, -- v0.18.0
	{ src = "https://github.com/sphamba/smear-cursor.nvim", version = "9e9378d6ee34bb3782e0e8c63d9ec8ca618b479b" },
	{ src = "https://github.com/mfussenegger/nvim-dap", version = "531771530d4f82ad2d21e436e3cc052d68d7aebb" },
	{ src = "https://github.com/nvim-neotest/nvim-nio", version = "21f5324bfac14e22ba26553caf69ec76ae8a7662" },
	{ src = "https://github.com/rcarriga/nvim-dap-ui", version = "1a66cabaa4a4da0be107d5eda6d57242f0fe7e49" },
	{ src = "https://github.com/theHamsta/nvim-dap-virtual-text", version = "fbdb48c2ed45f4a8293d0d483f7730d24467ccb6" },
	{ src = "https://github.com/leoluz/nvim-dap-go", version = "b4421153ead5d726603b02743ea40cf26a51ed5f" },
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
