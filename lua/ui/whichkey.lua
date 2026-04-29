local M = {}

function M.setup()
	require("which-key").setup({
		preset = "modern",
		delay = 300,
		icons = { mappings = false },
		spec = {
			{ "<leader>g", group = "git" },
			{ "<leader>f", group = "find" },
			{ "<leader>t", group = "tree" },
			{ "<leader>c", group = "code" },
		},
	})
end

M.setup()
return M
