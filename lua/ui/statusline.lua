local M = {}

function M.setup()
	require("mini.statusline").setup({
		use_icons = true,
	})
end

M.setup()
return M
