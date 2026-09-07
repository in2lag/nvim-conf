local M = {}

-- Back/forward history for the main editing windows, as a ring: going back from
-- the oldest file lands on the newest and vice versa, so neither key ever dead-ends.
--
-- `:bprevious`/`:bnext` walk buffer *number* order, i.e. the order buffers were
-- created, which has nothing to do with the order you visited files. Pickers,
-- `auto-session` restores and the peek promote hook all append to that list, so
-- H/L used to wander through files opened minutes ago in an order nobody can
-- predict. This records where you have actually been instead.
--
-- Only real files in non-floating windows are recorded: floats (peek windows,
-- snacks pickers, lazygit) and every `buftype` that is not a file (nvim-tree,
-- terminals, pickers, quickfix) are skipped, so navigating a picker never
-- pollutes the history it is used to navigate.

local history = {} ---@type integer[] oldest -> newest
local index = 0 -- position in `history`; the buffer we are currently sitting on

local MAX = 100

local function is_float(win)
	return vim.api.nvim_win_get_config(win).relative ~= ""
end

local function is_file_buf(buf)
	return vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "" and vim.api.nvim_buf_get_name(buf) ~= ""
end

local function record(buf)
	if is_float(vim.api.nvim_get_current_win()) or not is_file_buf(buf) then
		return
	end
	-- Already sitting on this entry: either BufEnter firing again because you
	-- switched windows back onto the same file, or the BufEnter from our own
	-- back()/forward() jump, which moves `index` before switching precisely so
	-- this check absorbs it. A separate "am I navigating" flag looked tempting
	-- here, but one cleared on vim.schedule stays stuck for a whole synchronous
	-- run of jumps and edits and silently drops every visit in it.
	if history[index] == buf then
		return
	end

	-- A new visit truncates the forward branch, exactly like a browser.
	for i = #history, index + 1, -1 do
		history[i] = nil
	end

	table.insert(history, buf)
	if #history > MAX then
		table.remove(history, 1)
	end
	index = #history
end

-- Remove every entry for `buf`, keeping the pointer on the entry it was on.
local function forget(buf)
	for i = #history, 1, -1 do
		if history[i] == buf then
			table.remove(history, i)
			if index >= i then
				index = index - 1
			end
		end
	end
	index = math.max(index, math.min(1, #history))
end

-- Step `step` entries through the history, wrapping past either end, and skip
-- buffers deleted since we recorded them so a wiped file costs one keypress
-- rather than stranding the walk. Bounded to one lap: if the only live entry
-- left is the one we are already on there is nowhere to go, and an unbounded
-- ring would spin forever looking.
local function jump(step)
	if is_float(vim.api.nvim_get_current_win()) then
		return vim.notify("Not in a main window", vim.log.levels.WARN, { title = "Buffer history" })
	end

	local n = #history
	if n == 0 then
		return vim.notify("History is empty", vim.log.levels.INFO, { title = "Buffer history" })
	end

	local i = index
	for _ = 1, n do
		i = i + step
		if i < 1 then
			i = n
		elseif i > n then
			i = 1
		end
		if i == index then
			break -- came all the way round to ourselves
		end
		if is_file_buf(history[i]) then
			-- Move the pointer first: record() reads it to recognise this switch as
			-- ours and not a new visit.
			index = i
			vim.api.nvim_set_current_buf(history[i])
			return
		end
	end

	vim.notify("No other file in history", vim.log.levels.INFO, { title = "Buffer history" })
end

function M.back()
	jump(-1)
end

function M.forward()
	jump(1)
end

function M.setup()
	vim.api.nvim_create_autocmd("BufEnter", {
		group = vim.api.nvim_create_augroup("buf-history", { clear = true }),
		callback = function(args)
			record(args.buf)
		end,
	})

	-- Drop dead buffers rather than carrying holes, and keep the pointer aimed at
	-- the same entry it was on.
	vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
		group = "buf-history",
		callback = function(args)
			forget(args.buf)
		end,
	})

	-- `:q` closes a window; with 'hidden' the buffer survives, listed and still in
	-- our history, so a file you deliberately closed would keep coming back under
	-- H/L. Forget it instead.
	--
	-- QuitPre is deliberately narrow. WinClosed would look equivalent and is not:
	-- it also fires when a peek float closes, and goto-preview resolves its target
	-- through vim.uri_to_bufnr, which hands back the *listed* bufnr when the file
	-- is already open -- so dismissing a peek would silently evict that file from
	-- the history. QuitPre only fires for the :q family, and peek closes its
	-- floats through nvim_win_close.
	vim.api.nvim_create_autocmd("QuitPre", {
		group = "buf-history",
		callback = function(args)
			-- Visible in another real window too: closing one of them is not closing
			-- the file, so leave the history alone.
			local shown = 0
			for _, win in ipairs(vim.api.nvim_list_wins()) do
				if not is_float(win) and vim.api.nvim_win_get_buf(win) == args.buf then
					shown = shown + 1
				end
			end
			if shown <= 1 then
				forget(args.buf)
			end
		end,
	})

	vim.keymap.set("n", "H", M.back, { desc = "Back to previous file" })
	vim.keymap.set("n", "L", M.forward, { desc = "Forward to next file" })

	-- Inspect the stack when the jumps do not go where you expect. `>` marks the
	-- current position; entries above it are what H reaches, below it what L does.
	vim.api.nvim_create_user_command("BufHistory", function()
		if #history == 0 then
			return vim.notify("History is empty", vim.log.levels.INFO, { title = "Buffer history" })
		end
		local lines = {}
		for i, buf in ipairs(history) do
			table.insert(
				lines,
				("%s %d. %s"):format(
					i == index and ">" or " ",
					i,
					vim.api.nvim_buf_is_valid(buf) and vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":~:.")
						or "(deleted)"
				)
			)
		end
		vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = "Buffer history" })
	end, { desc = "Show main-window file history" })
end

M.setup()
return M
