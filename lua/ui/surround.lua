local M = {}

function M.setup()
	require("mini.surround").setup({
		search_method = "cover_or_next",
	})
end

M.setup()
return M
