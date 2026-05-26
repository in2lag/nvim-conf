-- lua/ui/numbers.lua

local M = {}

-- Pull the gitsigns + diagnostic signs for this line. Returns nil for any
-- sign that isn't present so the caller can pack whatever exists to the left.
local function line_signs(bufnr, lnum)
	local git, diag
	local ok, marks = pcall(vim.api.nvim_buf_get_extmarks, bufnr, -1, { lnum - 1, 0 }, { lnum - 1, -1 }, {
		details = true,
		type = "sign",
	})
	if not ok then
		return git, diag
	end
	for _, mark in ipairs(marks) do
		local d = mark[4]
		if d and d.sign_text then
			local hl = d.sign_hl_group or ""
			local text = (d.sign_text:gsub("%s+$", ""))
			if hl:find("GitSigns") then
				git = "%#" .. hl .. "#" .. text
			elseif hl:find("Diagnostic") then
				diag = "%#" .. hl .. "#" .. text
			end
		end
	end
	return git, diag
end

-- This is the function Neovim will call for every line in the gutter
_G.my_statuscol = function()
	local lnum = vim.v.lnum
	local relnum = vim.v.relnum
	local bufnr = vim.api.nvim_win_get_buf(vim.g.statusline_winid or 0)
	local git, diag = line_signs(bufnr, lnum)

	-- Pack any present signs to the left; fill remaining cells with spaces
	-- so line numbers stay aligned regardless of which signs exist.
	local signs
	if git and diag then
		signs = git .. diag
	elseif git then
		signs = git .. " "
	elseif diag then
		signs = diag .. " "
	else
		signs = "  "
	end

	return signs
		.. "%="
		.. "%#CursorLineNr#"
		.. string.format("%-3d", relnum)
		.. " "
		.. "%#LineNr#"
		.. string.format("%3d", lnum)
		.. " "
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
