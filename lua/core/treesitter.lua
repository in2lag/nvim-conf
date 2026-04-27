local M = {}

function M.setup()
  require('tree-sitter-manager').setup({
    ensure_installed = { 'typescript', 'tsx', 'javascript', 'svelte', 'html', 'css' },
  })
end

M.setup()
return M
