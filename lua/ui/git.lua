local M = {}

function M.setup()
	local function blame_formatter(_, info)
		local lnum = vim.api.nvim_win_get_cursor(0)[1]
		if #vim.diagnostic.get(0, { lnum = lnum - 1 }) > 0 then
			return {}
		end
		if not info.author then
			return {}
		end
		local parts = { info.author }
		if info.author_time then
			table.insert(parts, os.date("%R", info.author_time))
		end
		local text = table.concat(parts, ", ")
		if info.summary and info.summary ~= "" then
			text = text .. " • " .. info.summary
		end
		return { { text, "GitSignsCurrentLineBlame" } }
	end

	require("gitsigns").setup({
		current_line_blame = true,
		current_line_blame_opts = {
			delay = 0,
			virt_text_pos = "eol",
		},
		current_line_blame_formatter = blame_formatter,
		on_attach = function(bufnr)
			local gs = package.loaded.gitsigns
			vim.keymap.set("n", "]c", gs.next_hunk, { buffer = bufnr, desc = "Next Change" })
			vim.keymap.set("n", "[c", gs.prev_hunk, { buffer = bufnr, desc = "Prev Change" })
			vim.keymap.set(
				"n",
				"<leader>gp",
				gs.preview_hunk_inline,
				{ buffer = bufnr, desc = "Preview Change Inline" }
			)
			vim.keymap.set(
				"n",
				"<leader>gt",
				gs.toggle_current_line_blame,
				{ buffer = bufnr, desc = "Toggle Line Blame" }
			)
		end,
	})

	local function apply_diff_hl()
		local bg = "#363a4a"
		local add_bg = "#2c3a2e"
		local del_bg = "#3d2c2c"
		local txt_add = "#3a4f30"
		vim.api.nvim_set_hl(0, "DiffAdd", { bg = add_bg })
		vim.api.nvim_set_hl(0, "DiffDelete", { bg = del_bg, fg = "#737994" })
		vim.api.nvim_set_hl(0, "DiffChange", { bg = bg })
		vim.api.nvim_set_hl(0, "DiffText", { bg = txt_add })
		vim.api.nvim_set_hl(0, "GitSignsCurrentLineBlame", { fg = "#949cbb", italic = true })
	end
	apply_diff_hl()
	vim.api.nvim_create_autocmd("ColorScheme", { callback = apply_diff_hl })

	-- When diagnostics change while the cursor sits still, fake a CursorMoved
	-- so gitsigns re-runs the blame formatter and the suppression kicks in
	-- without waiting for the next real cursor move.
	vim.api.nvim_create_autocmd("DiagnosticChanged", {
		callback = function(args)
			if args.buf == vim.api.nvim_get_current_buf() then
				vim.api.nvim_exec_autocmds("CursorMoved", { modeline = false })
			end
		end,
	})

	-- lazygit in a float, via snacks: staging, commits, rebases, stash, log.
	-- snacks themes it from the colorscheme and sets os.editPreset = "nvim-remote",
	-- so pressing `e` on a file opens it in THIS nvim instead of nesting a new one.
	vim.keymap.set("n", "<leader>gd", function()
		Snacks.lazygit()
	end, { desc = "Lazygit" })
end

M.setup()
return M
