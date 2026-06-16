local M = {}

function M.setup()
	require("smear_cursor").setup({
		-- Smear only when navigating; keep typing in insert mode crisp.
		smear_insert_mode = false,
	})
end

M.setup()
return M
