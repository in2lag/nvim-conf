vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.pack.add({
  { src = 'https://github.com/romus204/tree-sitter-manager.nvim' },
  { src = 'https://github.com/neovim/nvim-lspconfig' },
  { src = 'https://github.com/ellisonleao/gruvbox.nvim' },
  { src = 'https://github.com/nvim-tree/nvim-tree.lua' },
  { src ='https://github.com/nvim-tree/nvim-web-devicons' },
  { src = 'https://github.com/nvim-lua/plenary.nvim' },
  { src = 'https://github.com/nvim-telescope/telescope.nvim' },
  { src = 'https://github.com/lewis6991/gitsigns.nvim'},
  { src = 'https://github.com/sindrets/diffview.nvim'},
})

if vim.loader then vim.loader.enable() end

require('core.keymaps')
require('ui.git')
require('ui.search')
require('ui.tree')
require('ui.numbers')
require("gruvbox").setup()
vim.cmd.colorscheme("gruvbox")

require("tree-sitter-manager").setup({
  --- Default Options
  ensure_installed = {"typescript", "tsx", "javascript", "svelte", "html", "css"}, -- list of parsers to install at the start of a neovim session
  -- border = nil, -- border style for the window (e.g. "rounded", "single"), if nil, use the default border style defined by 'vim.o.winborder'. See :h 'winborder' for more info.
  -- auto_install = false, -- if enabled, install missing parsers when editing a new file
  -- highlight = true, -- treesitter highlighting is enabled by default
  -- languages = {}, -- override or add new parser sources
  -- parser_dir = vim.fn.stdpath("data") .. "/site/parser",
  -- query_dir = vim.fn.stdpath("data") .. "/site/queries",
})


vim.lsp.config('vtsls', {
  -- Configuration for the server goes here
  settings = {
    typescript = {
      updateImportsOnFileMove = { enabled = "always" },
      inlayHints = {
        parameterNames = { enabled = "all" },
        variableTypes = { enabled = true },
      },
    },
  },
})
vim.lsp.enable('vtsls')


-- Autocomplete
vim.keymap.set('i', '<Tab>', function()
  return vim.fn.pumvisible() == 1 and "<C-n>" or "<Tab>"
end, { expr = true })
vim.keymap.set('i', '<S-Tab>', function()
  return vim.fn.pumvisible() == 1 and "<C-p>" or "<S-Tab>"
end, { expr = true })
vim.keymap.set('i', '<CR>', function()
  return vim.fn.pumvisible() == 1 and "<C-y>" or "<CR>"
end, { expr = true })
vim.opt.complete = ".,w,b,u,t"
vim.opt.infercase = true
vim.opt.completeopt = { "menu", "menuone", "noinsert" }
vim.opt.autocompletedelay = 100 -- ms before menu appears
vim.opt.pumheight = 10
vim.opt.smartcase = true
vim.opt.completeopt:append("nearest")
vim.g.complete_priority = { lsp = 10, buffer = 5, snippets = 8 }
vim.o.autocomplete = true



vim.keymap.set('n', '<leader>h', '<cmd>nohlsearch<CR>', { desc = "Hide highlights" })
