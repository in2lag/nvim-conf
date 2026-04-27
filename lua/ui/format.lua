local M = {}

function M.setup()
  local web = { 'prettier', 'eslint_d' }
  local util = require('conform.util')

  require('conform').setup({
    formatters = {
      eslint_d = {
        cwd = util.root_file({
          'eslint.config.mjs',
          'eslint.config.js',
          'eslint.config.cjs',
          'eslint.config.ts',
          '.eslintrc.json',
          '.eslintrc.js',
          '.eslintrc.cjs',
        }),
        require_cwd = true,
      },
      prettier = {
        cwd = util.root_file({
          '.prettierrc',
          '.prettierrc.json',
          '.prettierrc.js',
          '.prettierrc.cjs',
          '.prettierrc.mjs',
          'prettier.config.js',
          'prettier.config.mjs',
          'prettier.config.cjs',
          'package.json',
        }),
      },
    },
    formatters_by_ft = {
      javascript     = web,
      javascriptreact = web,
      typescript     = web,
      typescriptreact = web,
      svelte         = web,
      vue            = web,
      html           = { 'prettier' },
      css            = { 'prettier' },
      scss           = { 'prettier' },
      json           = { 'prettier' },
      jsonc          = { 'prettier' },
      yaml           = { 'prettier' },
      markdown       = { 'prettier' },
      lua            = { 'stylua' },
    },
    format_on_save = function(bufnr)
      if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
        return
      end
      return { timeout_ms = 3000, lsp_format = 'fallback' }
    end,
  })

  vim.api.nvim_create_user_command('FormatDisable', function(args)
    if args.bang then
      vim.b.disable_autoformat = true
    else
      vim.g.disable_autoformat = true
    end
  end, { desc = 'Disable autoformat-on-save', bang = true })

  vim.api.nvim_create_user_command('FormatEnable', function()
    vim.b.disable_autoformat = false
    vim.g.disable_autoformat = false
  end, { desc = 'Re-enable autoformat-on-save' })

  vim.keymap.set({ 'n', 'v' }, '<leader>cf', function()
    require('conform').format({ async = true, lsp_format = 'fallback' })
  end, { desc = 'Format buffer' })
end

M.setup()
return M
