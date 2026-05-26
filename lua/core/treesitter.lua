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
			"yaml",
			"toml",
		},
	})

	-- jsonc has no dedicated parser in tree-sitter-manager; reuse json.
	vim.treesitter.language.register("json", "jsonc")
end

M.setup()
return M
