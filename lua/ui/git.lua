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

	-- <leader>go: open the PR that introduced the line under the cursor. git blame
	-- gives the commit, then GitHub's "pull requests associated with a commit"
	-- endpoint maps it back to the PR -- squash, merge and rebase commits all
	-- resolve, because the endpoint matches the merge result and not just heads.
	local function pr_notify(msg, level)
		vim.notify(msg, level or vim.log.levels.INFO, { title = "Open PR" })
	end

	local function gh(args, cwd, on_result)
		vim.system(vim.list_extend({ "gh" }, args), { cwd = cwd, text = true }, function(res)
			vim.schedule(function()
				on_result(res.code == 0 and vim.trim(res.stdout or "") or "")
			end)
		end)
	end

	local function open_pr_for_line()
		if vim.fn.executable("gh") == 0 then
			return pr_notify("gh not found -- brew install gh", vim.log.levels.ERROR)
		end
		local file = vim.api.nvim_buf_get_name(0)
		if file == "" or not vim.uv.fs_stat(file) then
			return pr_notify("Buffer is not a file on disk", vim.log.levels.WARN)
		end
		-- Run git and gh from the file's own directory: the {owner}/{repo}
		-- placeholders resolve from the remote there, which is not necessarily
		-- nvim's cwd once auto-session or a picker has moved us around.
		local cwd = vim.fn.fnamemodify(file, ":h")
		local lnum = vim.api.nvim_win_get_cursor(0)[1]

		-- Blame the *buffer*, not the file on disk: with unsaved edits above the
		-- cursor the two disagree about which line is which, and you would land on
		-- the PR for a neighbouring line.
		vim.system({
			"git",
			"blame",
			"-L",
			lnum .. ",+1",
			"--porcelain",
			"--contents",
			"-",
			"--",
			file,
		}, {
			cwd = cwd,
			text = true,
			stdin = vim.api.nvim_buf_get_lines(0, 0, -1, false),
		}, function(res)
			local sha = res.code == 0 and (res.stdout or ""):match("^(%x+)") or nil
			vim.schedule(function()
				if not sha then
					return pr_notify(vim.trim(res.stderr or "git blame failed"), vim.log.levels.ERROR)
				end
				-- All-zero sha: blame's marker for a line that exists only in the buffer.
				if sha:match("^0+$") then
					return pr_notify("Line is not committed yet", vim.log.levels.WARN)
				end

				local short = sha:sub(1, 8)
				local function open(url)
					pr_notify(("%s -> %s"):format(short, url))
					vim.ui.open(url)
				end

				gh(
					{ "api", "repos/{owner}/{repo}/commits/" .. sha .. "/pulls", "--jq", ".[0].html_url" },
					cwd,
					function(url)
						if url ~= "" then
							return open(url)
						end
						-- Nothing associated: the commit was pushed straight to a branch, or a
						-- rebase rewrote the sha the PR actually carried. Search PR text next.
						local search = {
							"pr",
							"list",
							"--search",
							sha,
							"--state",
							"all",
							"--limit",
							"1",
							"--json",
							"url",
							"--jq",
							".[0].url",
						}
						gh(search, cwd, function(found)
							if found ~= "" then
								return open(found)
							end
							-- No PR exists (this config's own history, for one). The commit page
							-- is the next most useful thing, so land there instead of erroring.
							pr_notify(("No PR for %s -- opening the commit"):format(short), vim.log.levels.WARN)
							Snacks.gitbrowse({ what = "commit", commit = sha, notify = false })
						end)
					end
				)
			end)
		end)
	end

	vim.keymap.set("n", "<leader>go", open_pr_for_line, { desc = "Open PR for current line" })

	-- lazygit in a float, via snacks: staging, commits, rebases, stash, log.
	-- snacks themes it from the colorscheme and sets os.editPreset = "nvim-remote",
	-- so pressing `e` on a file opens it in THIS nvim instead of nesting a new one.
	vim.keymap.set("n", "<leader>gd", function()
		Snacks.lazygit()
	end, { desc = "Lazygit" })
end

M.setup()
return M
