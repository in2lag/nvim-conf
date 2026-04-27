local M = {}

function M.setup()
  vim.lsp.config('vtsls', {
    settings = {
      typescript = {
        updateImportsOnFileMove = { enabled = "always" },
        inlayHints = {
          parameterNames = { enabled = "all" },
          variableTypes = { enabled = true },
        },
      },
    },
  })
  vim.lsp.enable('vtsls')
end

M.setup()
return M
