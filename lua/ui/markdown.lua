local M = {}

function M.setup()
  require('render-markdown').setup({
    file_types = { 'markdown' },
    completions = { lsp = { enabled = true } },
    heading = {
      sign = false,
      icons = {},
      width = 'full',
      border = false,
      backgrounds = {},
      foregrounds = {},
    },
    code = {
      sign = false,
      width = 'block',
      min_width = 60,
    },
    checkbox = {
      unchecked = { icon = '󰄱 ' },
      checked   = { icon = '󰱒 ' },
    },
  })

  local function set_heading_hls()
    local levels = {
      { '#fb4934' }, { '#fe8019' }, { '#fabd2f' },
      { '#b8bb26' }, { '#83a598' }, { '#d3869b' },
    }
    for i, c in ipairs(levels) do
      local opts = { fg = c[1], bold = true }
      vim.api.nvim_set_hl(0, '@markup.heading.' .. i .. '.markdown', opts)
      vim.api.nvim_set_hl(0, '@markup.heading.' .. i, opts)
      vim.api.nvim_set_hl(0, 'markdownH' .. i, opts)
    end
  end
  set_heading_hls()
  vim.api.nvim_create_autocmd('ColorScheme', {
    group = vim.api.nvim_create_augroup('RenderMarkdownHeadingHL', { clear = true }),
    callback = set_heading_hls,
  })

  vim.keymap.set('n', '<leader>mp', '<cmd>RenderMarkdown toggle<CR>',
    { desc = 'Toggle Markdown render' })
end

M.setup()
return M
