local M = {}

function M.setup()
	require("tree-sitter-manager").setup({
		ensure_installed = {
			"typescript",
			"tsx",
			"javascript",
			"svelte",
			"html",
			"css",
			"markdown",
			"markdown_inline",
			"go",
			"gomod",
			"gosum",
			"gowork",
			"lua",
			"vim",
			"vimdoc",
			"query",
			"bash",
			"json",
			"jsonc",
			"yaml",
			"toml",
		},
	})
end

M.setup()
return M
