local M = {}

-- How long the buffer must go without an edit before diagnostics reappear.
local DEBOUNCE_MS = 500

-- vim.diagnostic has no delay/debounce option, so do it by hand: hide a buffer's
-- diagnostics on every edit and bring them back once typing stops. `update_in_insert`
-- stays true so what reappears is current rather than stale -- it controls whether
-- diagnostics are *recomputed* in insert mode, this controls whether they are *shown*.
--
-- Generation counter rather than a timer handle per buffer: each edit invalidates the
-- pending callback simply by bumping the count, so there are no timers to stop, close,
-- or leak on buffer wipeout.
local function setup_debounce()
	local generation = {}
	local group = vim.api.nvim_create_augroup("diagnostics-debounce", { clear = true })

	local function show(buf)
		if vim.api.nvim_buf_is_valid(buf) and not vim.diagnostic.is_enabled({ bufnr = buf }) then
			vim.diagnostic.enable(true, { bufnr = buf })
		end
	end

	vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "TextChangedP" }, {
		group = group,
		callback = function(args)
			local buf = args.buf
			generation[buf] = (generation[buf] or 0) + 1
			local mine = generation[buf]

			if vim.diagnostic.is_enabled({ bufnr = buf }) then
				vim.diagnostic.enable(false, { bufnr = buf })
			end

			vim.defer_fn(function()
				if generation[buf] == mine then
					show(buf)
				end
			end, DEBOUNCE_MS)
		end,
	})

	-- Leaving insert means you have stopped typing, so don't sit on a blank buffer
	-- for the rest of the delay.
	vim.api.nvim_create_autocmd("InsertLeave", {
		group = group,
		callback = function(args)
			generation[args.buf] = (generation[args.buf] or 0) + 1
			show(args.buf)
		end,
	})

	vim.api.nvim_create_autocmd({ "BufWipeout", "BufDelete" }, {
		group = group,
		callback = function(args)
			generation[args.buf] = nil
		end,
	})
end

function M.setup()
	local severity = vim.diagnostic.severity

	vim.diagnostic.config({
		virtual_text = {
			spacing = 2,
			priority = 10,
			prefix = "",
			format = function(d)
				return d.message
			end,
		},
		signs = {
			text = {
				[severity.ERROR] = "┃",
				[severity.WARN] = "┃",
				[severity.INFO] = "┃",
				[severity.HINT] = "┃",
			},
		},
		severity_sort = true,
		-- Kept true on purpose: setup_debounce() gates *display*, so diagnostics must
		-- still be recomputed while inserting or the ones that reappear would be stale.
		update_in_insert = true,
		float = {
			border = "rounded",
			source = true,
			header = "",
		},
	})

	setup_debounce()

	local map = vim.keymap.set
	map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line diagnostics" })
	map("n", "<leader>cq", function()
		Snacks.picker.diagnostics()
	end, { desc = "Project diagnostics" })
end

M.setup()
return M
