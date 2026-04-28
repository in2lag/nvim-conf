local M = {}

function M.setup()
  require('render-markdown').setup({
    file_types = { 'markdown' },
    completions = { lsp = { enabled = true } },
    heading = {
      sign = false,
      icons = { '󰲡 ', '󰲣 ', '󰲥 ', '󰲧 ', '󰲩 ', '󰲫 ' },
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

  vim.keymap.set('n', '<leader>mp', '<cmd>RenderMarkdown toggle<CR>',
    { desc = 'Toggle Markdown render' })
end

M.setup()
return M
