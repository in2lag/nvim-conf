-- lua/ui/numbers.lua

local M = {}

-- This is the function Neovim will call for every line in the gutter
_G.my_statuscol = function()
	local lnum = vim.v.lnum
	local relnum = vim.v.relnum

	-- 1. Sign Column (Git signs, etc.)
	local parts = { "%s" }

	-- 2. Push to the right
	table.insert(parts, "%=")

	-- 3. Relative Number (Left Aligned)
	-- Uses the CursorLineNr highlight
	table.insert(parts, "%#CursorLineNr#" .. string.format("%-3d", relnum) .. " ")

	-- 4. Absolute Number (Right Aligned)
	-- Uses the standard LineNr highlight
	table.insert(parts, "%#LineNr#" .. string.format("%3d", lnum) .. " ")

	return table.concat(parts, "")
end

function M.setup()
	vim.opt.number = true
	vim.opt.relativenumber = true

	-- Tell Neovim to use our Lua function to render the gutter
	-- This is the most efficient and error-proof way in v0.12
	vim.opt.statuscolumn = "%!v:lua.my_statuscol()"

	-- Apply Colors
	local function apply_colors()
		vim.api.nvim_set_hl(0, "LineNr", { fg = "#babbf1" })
		vim.api.nvim_set_hl(0, "LineNrAbove", { fg = "#8caaee" })
		vim.api.nvim_set_hl(0, "LineNrBelow", { fg = "#ca9ee6" })
		vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#ef9f76", bold = true })
	end

	vim.api.nvim_create_autocmd("ColorScheme", {
		pattern = "*",
		callback = apply_colors,
	})

	apply_colors()
end

M.setup()

return M
