-- lua/ui/cursorline.lua

local M = {}

function M.setup()
	-- Highlight both the line background and the number gutter.
	vim.opt.cursorlineopt = "both"

	local group = vim.api.nvim_create_augroup("SmartCursorline", { clear = true })

	-- Show the cursorline only in the focused, non-insert window so splits
	-- and insert mode stay uncluttered.
	vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter", "InsertLeave" }, {
		group = group,
		callback = function()
			vim.opt_local.cursorline = true
		end,
	})

	vim.api.nvim_create_autocmd({ "WinLeave", "InsertEnter" }, {
		group = group,
		callback = function()
			vim.opt_local.cursorline = false
		end,
	})

	-- Keep the current window lit on startup.
	vim.opt_local.cursorline = true
end

M.setup()

return M
