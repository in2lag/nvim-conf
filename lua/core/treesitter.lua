local M = {}

function M.setup()
	require("tree-sitter-manager").setup({
		ensure_installed = {
			"html",
			"css",
			"markdown",
			"markdown_inline",
			"lua",
			"vim",
			"vimdoc",
			"query",
			"bash",
			"json",
			"yaml",
			"toml",
		},
	})

	-- jsonc has no dedicated parser in tree-sitter-manager; reuse json.
	vim.treesitter.language.register("json", "jsonc")
end

M.setup()
return M
