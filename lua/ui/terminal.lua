local M = {}

function M.setup()
  require("toggleterm").setup({
    direction = 'float',
    -- Set winblend to 0 to fix the lag you're experiencing
    float_opts = {
      border = 'curved',
      winblend = 0, 
    },
    -- These three ensure you are always ready to type
    start_in_insert = true,
    insert_mappings = true, 
    terminal_mappings = true,
    persist_mode = false, -- Don't remember if I was in Normal mode
  })

  -- AUTO-INSERT: Force terminal mode whenever you click into the terminal
  vim.api.nvim_create_autocmd({"BufEnter", "WinEnter"}, {
    pattern = "term://*",
    command = "startinsert",
  })

  -- NAVIGATION: Use Cmd/Alt or specific keys to switch windows instead of Esc
  -- We'll remove the Esc -> Normal mode mapping so Esc just goes to your shell
  -- vim.keymap.del('t', '<Esc>') -- Run this if you already have the mapping
  
  -- Kill terminal process shortcut (still useful)
  vim.keymap.set('t', '<leader>tk', [[<C-\><C-n>:bdelete!<CR>]], { desc = "Kill Terminal" })
  
  -- Toggle Terminal
  vim.keymap.set('n', '<leader>t', '<cmd>1ToggleTerm<CR>', { desc = "Toggle Terminal" })
end

M.setup()
return M
