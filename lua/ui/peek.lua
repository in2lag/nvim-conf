local M = {}

function M.setup()
  local gp = require('goto-preview')

  gp.setup({
    width = 120,
    height = 20,
    border = 'rounded',
    resizing_mappings = false,
    post_open_hook = function(buf, _)
      vim.keymap.set('n', 'q', function() gp.close_all_win() end,
        { buffer = buf, nowait = true, desc = "Close peek" })
      vim.keymap.set('n', '<Esc>', function() gp.close_all_win() end,
        { buffer = buf, nowait = true, desc = "Close peek" })
      vim.keymap.set('n', '<CR>', function()
        local name = vim.api.nvim_buf_get_name(0)
        local pos = vim.api.nvim_win_get_cursor(0)
        gp.close_all_win()
        if name ~= '' then
          vim.cmd('edit ' .. vim.fn.fnameescape(name))
          pcall(vim.api.nvim_win_set_cursor, 0, pos)
        end
      end, { buffer = buf, nowait = true, desc = "Promote peek to buffer" })
    end,
  })

  local map = vim.keymap.set
  map('n', 'gpd', gp.goto_preview_definition,      { desc = "Peek definition" })
  map('n', 'gpi', gp.goto_preview_implementation,  { desc = "Peek implementation" })
  map('n', 'gpt', gp.goto_preview_type_definition, { desc = "Peek type definition" })
  map('n', 'gpr', gp.goto_preview_references,      { desc = "Peek references" })
  map('n', 'gpc', gp.close_all_win,                { desc = "Close all peek windows" })
end

M.setup()
return M
