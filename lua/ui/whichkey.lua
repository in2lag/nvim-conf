local M = {}

function M.setup()
	require("which-key").setup({
		preset = "modern",
		delay = 200,
		icons = { mappings = false },
		spec = {
			{ "<leader>g", group = "git" },
			{ "<leader>f", group = "find" },
			{ "<leader>c", group = "code" },
			{ "<leader>d", group = "debug" },
			{ "<leader>s", group = "search" },
			{ "<leader>m", group = "markdown" },
			{ "s", group = "surround" },
		},
	})
end

M.setup()
return M
