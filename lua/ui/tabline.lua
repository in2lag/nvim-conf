local M = {}

-- One bar across the top showing the core.bufhistory ring in visit order, the
-- entry H/L are sitting on highlighted. No plugin: 'tabline' is a statusline
-- format string, so this builds one from the history array and hands it to
-- Neovim, which redraws it on its own whenever the screen changes.
--
-- This is the same list H and L walk, drawn instead of imagined: a new visit
-- appends at the right and clears the forward branch, H slides the highlight
-- left, L slides it right, and the entries a wiped buffer left behind are simply
-- not drawn. mini.tabline would have been two lines, but it lists buffers in
-- number order, which is the ordering H/L just moved away from.

local hist = require("core.bufhistory")

local HL_MOD = "TablineModified"
local HL_MOD_SEL = "TablineModifiedSel"

-- catppuccin styles TabLine (dimmed), TabLineSel (Normal fg on Normal bg, so
-- the current entry reads as connected to the buffer beneath it) and
-- TabLineFill. Only the modified marker needs groups of our own: warn colour on
-- each of the two backgrounds, re-derived on ColorScheme because init.lua
-- applies the colorscheme after this module loads.
local function define_highlights()
	local warn = vim.api.nvim_get_hl(0, { name = "DiagnosticWarn", link = false })
	local tab = vim.api.nvim_get_hl(0, { name = "TabLine", link = false })
	local sel = vim.api.nvim_get_hl(0, { name = "TabLineSel", link = false })
	vim.api.nvim_set_hl(0, HL_MOD, { fg = warn.fg, bg = tab.bg })
	vim.api.nvim_set_hl(0, HL_MOD_SEL, { fg = warn.fg, bg = sel.bg })
end

-- `%` is a statusline escape, so a literal one in a path must be doubled.
local function esc(str)
	return (str:gsub("%%", "%%%%"))
end

local function icon_for(name)
	local ok, devicons = pcall(require, "nvim-web-devicons")
	if not ok then
		return ""
	end
	-- By filename rather than filetype: buffers auto-session restored but has
	-- not loaded yet have no filetype, and the bar should not change shape as
	-- you visit them.
	local icon = devicons.get_icon(vim.fn.fnamemodify(name, ":t"), vim.fn.fnamemodify(name, ":e"), { default = true })
	return icon or ""
end

-- Basenames, with the parent directory prepended wherever two entries would
-- otherwise read the same (`index.ts` is every other file in a TS monorepo).
local function labels(bufs)
	local tails, counts = {}, {}
	for i, buf in ipairs(bufs) do
		tails[i] = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":t")
		counts[tails[i]] = (counts[tails[i]] or 0) + 1
	end
	local out = {}
	for i, buf in ipairs(bufs) do
		if counts[tails[i]] > 1 then
			out[i] = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":h:t") .. "/" .. tails[i]
		else
			out[i] = tails[i]
		end
	end
	return out
end

-- Left-click jumps, middle-click closes, like every browser tab bar. `pos` is
-- the history index, passed through the %N@ click handler's minwid slot.
function M.click(pos, _, button)
	if button == "l" then
		hist.jump_to(pos)
	elseif button == "m" then
		local history = hist.state()
		local buf = history[pos]
		if buf and vim.api.nvim_buf_is_valid(buf) then
			local ok, err = pcall(vim.cmd.bdelete, buf)
			if not ok then
				vim.notify(err, vim.log.levels.WARN, { title = "Buffer history" })
			end
		end
	end
end

function M.render()
	local history, index = hist.state()

	-- Live entries only; dead ones are skipped by H/L too, so drawing them would
	-- show stops the keys never make.
	local items = {}
	local bufs = {}
	for pos, buf in ipairs(history) do
		if hist.is_file_buf(buf) then
			bufs[#bufs + 1] = buf
			items[#items + 1] = { pos = pos, buf = buf, current = pos == index }
		end
	end
	if #items == 0 then
		return "%#TabLineFill#"
	end

	local names = labels(bufs)
	local current_i = 1
	for i, it in ipairs(items) do
		local name = vim.api.nvim_buf_get_name(it.buf)
		local hl = it.current and "TabLineSel" or "TabLine"
		local modified = vim.bo[it.buf].modified
		local text = string.format(" %s %s", icon_for(name), esc(names[i]))
		-- The marker sits inside the entry's padding so an edit does not shift
		-- everything to its right.
		local tail = modified and ("%#" .. (it.current and HL_MOD_SEL or HL_MOD) .. "#● ") or "  "
		it.str = string.format("%%%d@v:lua.require'ui.tabline'.click@%%#%s#%s %s%%X", it.pos, hl, text, tail)
		it.width = vim.fn.strdisplaywidth(text) + 3
		if it.current then
			current_i = i
		end
	end

	-- Everything fits: draw it all. Otherwise grow a window outwards from the
	-- current entry, alternating sides, and mark whichever side was cut.
	local columns = vim.o.columns
	local total = 0
	for _, it in ipairs(items) do
		total = total + it.width
	end

	local lo, hi = current_i, current_i
	if total > columns then
		local used = items[current_i].width + 2 -- room for the two cut markers
		while true do
			local grew = false
			if lo > 1 and used + items[lo - 1].width <= columns then
				lo = lo - 1
				used = used + items[lo].width
				grew = true
			end
			if hi < #items and used + items[hi + 1].width <= columns then
				hi = hi + 1
				used = used + items[hi].width
				grew = true
			end
			if not grew then
				break
			end
		end
	else
		lo, hi = 1, #items
	end

	local parts = {}
	if lo > 1 then
		parts[#parts + 1] = "%#TabLine#‹"
	end
	for i = lo, hi do
		parts[#parts + 1] = items[i].str
	end
	if hi < #items then
		parts[#parts + 1] = "%#TabLine#›"
	end
	parts[#parts + 1] = "%#TabLineFill#%="

	-- Tab pages are not part of this workflow, but if one gets opened the bar
	-- should at least admit it rather than hide the fact.
	local tabs = vim.fn.tabpagenr("$")
	if tabs > 1 then
		parts[#parts + 1] = string.format("%%#TabLine# tab %d/%d ", vim.fn.tabpagenr(), tabs)
	end

	return table.concat(parts)
end

function M.setup()
	define_highlights()
	vim.api.nvim_create_autocmd("ColorScheme", {
		group = vim.api.nvim_create_augroup("tabline-hl", { clear = true }),
		callback = define_highlights,
	})

	vim.o.showtabline = 2
	vim.o.tabline = "%!v:lua.require'ui.tabline'.render()"
end

M.setup()
return M
