local map = vim.keymap.set

-- [ Find ]
map('n', '<leader><leader>', '<cmd>Telescope find_files<CR>', { desc = "Fuzzy find files" })
map('n', '<leader>p', '<cmd>Telescope find_files<CR>', { desc = "Project Search" })
map('n', '<leader>ff', '<cmd>Telescope find_files<CR>', { desc = "Find files" })
map('n', '<leader>fg', '<cmd>Telescope live_grep<CR>', { desc = "Find in files (grep)" })
map('n', '<leader>fb', '<cmd>Telescope buffers<CR>', { desc = "Find buffer" })
map('n', '<leader>fr', '<cmd>Telescope oldfiles<CR>', { desc = "Recent files" })

-- [ General ]
map('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = "Clear highlights" })

-- [ Clipboard ]
map({'n', 'v'}, '<leader>y', '"+y', { desc = "Yank to system" })
map('n', '<leader>v', '"+p', { desc = "Paste from system" })
map("x", "<leader>P", [["_dP]], { desc = "Paste and keep yank" })

-- [ Deletion ]
map({'n', 'v'}, '<leader>x', '"_d', { desc = "Black hole delete" })

-- [ Editing ]
map('n', '<leader>d', 'yyp', { desc = "Duplicate line" })
map('v', '<leader>d', 'yP', { desc = "Duplicate selection" })

-- [ Smart Home ]
map('n', '<Home>', function()
  local col = vim.fn.col('.')
  local first_nonblank = vim.fn.indent(vim.fn.line('.')) + 1
  return col == first_nonblank and '0' or '^'
end, { expr = true, desc = "Smart Home" })

return {}
