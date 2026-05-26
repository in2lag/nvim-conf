local M = {}

-- Filetype with devicon, nothing else (no encoding, no format, no size).
local function filetype_only()
	local ft = vim.bo.filetype
	if ft == "" then
		return ""
	end
	local ok, devicons = pcall(require, "nvim-web-devicons")
	if ok then
		local icon = devicons.get_icon_by_filetype(ft, { default = false })
		if icon then
			return icon .. " " .. ft
		end
	end
	return ft
end

function M.setup()
	local s = require("mini.statusline")
	s.setup({
		use_icons = true,
		content = {
			active = function()
				local mode, mode_hl = s.section_mode({ trunc_width = 120 })
				local git = s.section_git({ trunc_width = 40 })
				local diff = s.section_diff({ trunc_width = 75 })
				local diagnostics = s.section_diagnostics({ trunc_width = 75 })
				local lsp = s.section_lsp({ trunc_width = 75 })
				local filename = s.section_filename({ trunc_width = 140 })
				local search = s.section_searchcount({ trunc_width = 75 })
				-- line:col only — no percentage through file
				local location = "%2l:%-2v"

				return s.combine_groups({
					{ hl = mode_hl, strings = { mode } },
					{ hl = "MiniStatuslineDevinfo", strings = { git, diff, diagnostics, lsp } },
					"%<",
					{ hl = "MiniStatuslineFilename", strings = { filename } },
					"%=",
					{ hl = "MiniStatuslineFileinfo", strings = { filetype_only() } },
					{ hl = mode_hl, strings = { search, location } },
				})
			end,
		},
	})
end

M.setup()
return M
