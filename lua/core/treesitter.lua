local M = {}

function M.setup()
	require("tree-sitter-manager").setup({
		ensure_installed = {
			"typescript",
			"tsx",
			"javascript",
			"svelte",
			"angular",
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

	-- Angular templates: detect *.component.html as htmlangular (the filetype
	-- angularls attaches to), map it to the angular parser, and start highlighting.
	-- tree-sitter-manager's auto-highlight keys off parser names, so it won't
	-- match htmlangular on its own -- wire it up explicitly here.
	vim.treesitter.language.register("angular", "htmlangular")
	vim.filetype.add({
		pattern = { [".*%.component%.html"] = "htmlangular" },
	})
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "htmlangular",
		callback = function(args)
			pcall(vim.treesitter.start, args.buf, "angular")
		end,
		desc = "Enable angular treesitter highlighting for templates",
	})
end

M.setup()
return M
