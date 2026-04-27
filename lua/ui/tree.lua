local M = {}

function M.setup()
  -- 1. Main Nvim-Tree Configuration
  require("nvim-tree").setup({
    sync_root_with_cwd = true,
    respect_buf_cwd = true,
    update_focused_file = {
      enable = true,
      update_root = true,
    },
    view = {
      width = 45,
      side = "left",
    },
    renderer = {
      highlight_git = true,
      indent_markers = { enable = true },
    },
  })

  -- 2. SMART NAVIGATION LOGIC (The "Boing" Toggle)
  vim.keymap.set('n', '<leader>e', function()
    local api = require("nvim-tree.api")
    local view = require("nvim-tree.view")

    if not view.is_visible() then
      -- 1. If closed: Open it
      api.tree.open()
    elseif vim.api.nvim_get_current_win() ~= view.get_winnr() then
      -- 2. If open but you are in code: Jump TO the tree
      api.tree.focus()
    else
      -- 3. If you are already in the tree: Jump BACK to the code
      vim.cmd("wincmd p")
    end
  end, { desc = "Focus Tree or Jump Back to Code" })

  -- 3. EXPLICIT CLOSE MAPPING
  -- Use Capital E to actually shut the sidebar down
  vim.keymap.set('n', '<leader>E', '<cmd>NvimTreeClose<CR>', { desc = "Close Tree Sidebar" })

  -- 4. AUTO-OPEN ON STARTUP
  local function open_nvim_tree(data)
    local real_file = vim.fn.filereadable(data.file) == 1
    local no_name = data.file == "" and vim.bo.buftype == ""
    if not real_file and not no_name then return end
    require("nvim-tree.api").tree.toggle({ focus = false, find_file = true })
  end
  vim.api.nvim_create_autocmd({ "VimEnter" }, { callback = open_nvim_tree })

end

M.setup()
return M
