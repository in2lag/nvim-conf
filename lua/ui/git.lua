local M = {}

function M.setup()
  require('gitsigns').setup({
    on_attach = function(bufnr)
      local gs = package.loaded.gitsigns
      vim.keymap.set('n', ']c', gs.next_hunk, { buffer = bufnr, desc = "Next Change" })
      vim.keymap.set('n', '[c', gs.prev_hunk, { buffer = bufnr, desc = "Prev Change" })
      vim.keymap.set('n', '<leader>gp', gs.preview_hunk_inline, { buffer = bufnr, desc = "Preview Change Inline" })
    end
  })

  local is_unified = true
  local function toggle_diff_view()
    vim.cmd('DiffviewClose')
    is_unified = not is_unified
    if is_unified then
      vim.cmd('DiffviewOpen --view-control=unified')
      print("Layout: Unified")
    else
      vim.cmd('DiffviewOpen')
      print("Layout: Split")
    end
  end

  vim.keymap.set('n', '<leader>gd', ':DiffviewOpen --view-control=unified<CR>', { desc = "Open Unified Diff" })
  vim.keymap.set('n', '<leader>gt', toggle_diff_view, { desc = "Toggle Split/Unified Layout" })
  vim.keymap.set('n', '<leader>gc', ':DiffviewClose<CR>', { desc = "Close DiffView" })
end

M.setup()
return M
