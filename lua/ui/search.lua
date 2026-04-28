local M = {}
function M.setup()
  vim.opt.hlsearch = true
  vim.opt.incsearch = true
  vim.opt.ignorecase = true
  vim.opt.smartcase = true

  local map = vim.keymap.set
  -- Keep search results centered
  map('n', 'n', 'nzzzv', { desc = "Next result (centered)" })
  map('n', 'N', 'Nzzzv', { desc = "Prev result (centered)" })
  -- Quick Search and Replace
  map('n', '<leader>sr', [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Search and Replace" })

  local actions = require('telescope.actions')
  require('telescope').setup({
    defaults = {
      vimgrep_arguments = {
        'rg', '--color=never', '--no-heading', '--with-filename',
        '--line-number', '--column', '--smart-case',
        '--hidden', '--glob=!**/.git/*',
      },
    },
    pickers = {
      find_files = {
        hidden = true,
        file_ignore_patterns = { '%.git/' },
      },
      buffers = {
        mappings = {
          i = { ['<C-d>'] = actions.delete_buffer },
          n = { ['dd']    = actions.delete_buffer },
        },
      },
    },
  })
end
M.setup()
return M
