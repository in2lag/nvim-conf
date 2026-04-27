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

  require('diffview').setup({
    enhanced_diff_hl = true,
    view = {
      default      = { layout = "diff2_horizontal", disable_diagnostics = true, winbar_info = true },
      file_history = { layout = "diff2_horizontal", disable_diagnostics = true, winbar_info = true },
    },
    file_panel = {
      listing_style = "tree",
      win_config = { position = "left", width = 32 },
    },
    hooks = {
      diff_buf_win_enter = function(_, _, ctx)
        if ctx.layout_name:match("^diff2") then
          vim.opt_local.signcolumn = "no"
          vim.opt_local.foldcolumn = "0"
          vim.opt_local.cursorline = true
          vim.opt_local.relativenumber = false
        end
        vim.keymap.set('n', 'q', '<cmd>DiffviewClose<CR>',
          { buffer = true, nowait = true, desc = "Close Diffview" })
      end,
      view_opened = function()
        vim.schedule(function()
          vim.cmd("wincmd l")
        end)
      end,
    },
  })

  vim.opt.scrollopt = "ver,jump"

  local function apply_diff_hl()
    local bg = "#3c3836"
    local add_bg = "#34381b"
    local del_bg = "#402120"
    local txt_add = "#3e4d24"
    local txt_del = "#5a2c2c"
    vim.api.nvim_set_hl(0, "DiffAdd",    { bg = add_bg })
    vim.api.nvim_set_hl(0, "DiffDelete", { bg = del_bg, fg = "#7c6f64" })
    vim.api.nvim_set_hl(0, "DiffChange", { bg = bg })
    vim.api.nvim_set_hl(0, "DiffText",   { bg = txt_add, bold = true })
    vim.api.nvim_set_hl(0, "DiffviewDiffAddAsDelete", { bg = del_bg })
    vim.api.nvim_set_hl(0, "DiffviewDiffDelete",      { fg = "#504945", bg = "NONE" })
    vim.api.nvim_set_hl(0, "DiffviewStatusModified",  { fg = "#fabd2f", bold = true })
    vim.api.nvim_set_hl(0, "DiffviewStatusAdded",     { fg = "#b8bb26", bold = true })
    vim.api.nvim_set_hl(0, "DiffviewStatusDeleted",   { fg = "#fb4934", bold = true })
    vim.api.nvim_set_hl(0, "DiffviewStatusRenamed",   { fg = "#83a598", bold = true })
    vim.api.nvim_set_hl(0, "DiffviewStatusUnmerged",  { fg = "#d3869b", bold = true })
    vim.api.nvim_set_hl(0, "DiffviewFilePanelTitle",  { fg = "#fe8019", bold = true })
    vim.api.nvim_set_hl(0, "DiffviewFilePanelCounter",{ fg = "#fabd2f", bold = true })
  end
  apply_diff_hl()
  vim.api.nvim_create_autocmd("ColorScheme", { callback = apply_diff_hl })

  local function toggle_diffview()
    local lib = require('diffview.lib')
    if lib.get_current_view() then
      vim.cmd('DiffviewClose')
    else
      vim.cmd('DiffviewOpen')
    end
  end

  vim.keymap.set('n', '<leader>gd', toggle_diffview, { desc = "Toggle Diffview" })

  vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'DiffviewFiles', 'DiffviewFileHistory' },
    callback = function(args)
      vim.keymap.set('n', 'q', '<cmd>DiffviewClose<CR>',
        { buffer = args.buf, nowait = true, desc = "Close Diffview" })
    end,
  })
end

M.setup()
return M
