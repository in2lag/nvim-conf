local M = {}

local HL_DIR = "StatuslineFileDir"
local HL_TAIL = "StatuslineFileTail"

-- Dim the directories, brighten the basename. Derived from the theme on every
-- ColorScheme so this tracks catppuccin instead of hardcoding colors.
local function define_highlights()
	local base = vim.api.nvim_get_hl(0, { name = "MiniStatuslineFilename", link = false })
	local comment = vim.api.nvim_get_hl(0, { name = "Comment", link = false })
	local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
	vim.api.nvim_set_hl(0, HL_DIR, { fg = comment.fg, bg = base.bg })
	vim.api.nvim_set_hl(0, HL_TAIL, { fg = normal.fg, bg = base.bg, bold = true })
end

-- `%` is a statusline escape, so a literal one in a path must be doubled.
local function esc(str)
	return (str:gsub("%%", "%%%%"))
end

-- mini's section_filename uses %F (absolute path) once the window is at least
-- trunc_width, so the wider the window the LONGER the path -- burying the
-- basename at the far end and repeating the branch name section_git already
-- shows. Always stay cwd-relative, dim the directories, and bold the basename;
-- drop to the basename alone when the window gets narrow.
--
-- combine_groups pads each group with spaces, which would put a gap mid-path, so
-- this returns ONE string carrying its own %#hl# switches.
local function filename_section(trunc_width)
	if vim.bo.buftype == "terminal" then
		return "%#" .. HL_TAIL .. "#%t"
	end

	local rel = vim.fn.expand("%:.")
	if rel == "" then
		return "%#" .. HL_TAIL .. "#[No Name]%m%r"
	end

	local tail = vim.fn.fnamemodify(rel, ":t")
	if require("mini.statusline").is_truncated(trunc_width) then
		return string.format("%%#%s#%s%%m%%r", HL_TAIL, esc(tail))
	end

	-- Keeps the trailing separator with the directory part; empty at cwd root.
	local dir = rel:sub(1, #rel - #tail)
	return string.format("%%#%s#%s%%#%s#%s%%m%%r", HL_DIR, esc(dir), HL_TAIL, esc(tail))
end

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
	-- init.lua applies the colorscheme after this module loads, so define now and
	-- re-derive on every ColorScheme.
	define_highlights()
	vim.api.nvim_create_autocmd("ColorScheme", {
		group = vim.api.nvim_create_augroup("statusline-filename-hl", { clear = true }),
		callback = define_highlights,
	})

	local s = require("mini.statusline")
	s.setup({
		use_icons = true,
		content = {
			active = function()
				local mode, mode_hl = s.section_mode({ trunc_width = 120 })
				-- No git branch or diff summary -- they only crowded out the
				-- filename. gitsigns still shows per-line state in the gutter, and
				-- 'titlestring' carries the cwd (worktree) name.
				local diagnostics = s.section_diagnostics({ trunc_width = 75 })
				local lsp = s.section_lsp({ trunc_width = 75 })
				local filename = filename_section(100)
				local search = s.section_searchcount({ trunc_width = 75 })
				-- line:col only — no percentage through file
				local location = "%2l:%-2v"

				return s.combine_groups({
					{ hl = mode_hl, strings = { mode } },
					{ hl = "MiniStatuslineDevinfo", strings = { diagnostics, lsp } },
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
