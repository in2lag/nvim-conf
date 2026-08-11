local M = {}

function M.setup()
	local gp = require("goto-preview")

	gp.setup({
		width = 120,
		height = 20,
		border = "rounded",
		resizing_mappings = false,
		references = { provider = "snacks" },
		post_open_hook = function(buf, _)
			vim.keymap.set("n", "q", function()
				pcall(vim.api.nvim_win_close, 0, false)
			end, { buffer = buf, nowait = true, desc = "Close this peek window" })
			vim.keymap.set("n", "Q", function()
				gp.close_all_win()
			end, { buffer = buf, nowait = true, desc = "Close all peek windows" })
			vim.keymap.set("n", "<CR>", function()
				local name = vim.api.nvim_buf_get_name(0)
				local pos = vim.api.nvim_win_get_cursor(0)
				gp.close_all_win()
				if name ~= "" then
					vim.cmd("edit " .. vim.fn.fnameescape(name))
					pcall(vim.api.nvim_win_set_cursor, 0, pos)
				end
			end, { buffer = buf, nowait = true, desc = "Promote peek to buffer" })
		end,
	})

	-- goto-preview reports failure with print(), which bypasses vim.notify and so
	-- is swallowed by cmdheight=0 (it only shows as a "press ENTER" prompt whose
	-- text you never see). The common cause is no attached server supporting the
	-- method -- e.g. a globally-npm-installed server orphaned by an nvm switch.
	-- Check that up front and report it through the notifier instead.
	local function peek(fn, method)
		return function()
			local capable = vim.lsp.get_clients({ bufnr = 0, method = method })
			if #capable == 0 then
				local attached = vim.tbl_map(function(c)
					return c.name
				end, vim.lsp.get_clients({ bufnr = 0 }))
				vim.notify(
					("No LSP server supports %s for this buffer (ft=%s).\nAttached: %s"):format(
						method,
						vim.bo.filetype,
						#attached > 0 and table.concat(attached, ", ") or "none"
					),
					vim.log.levels.WARN,
					{ title = "Peek" }
				)
				return
			end
			fn()
		end
	end

	local map = vim.keymap.set
	map("n", "gpd", peek(gp.goto_preview_definition, "textDocument/definition"), { desc = "Peek definition" })
	map(
		"n",
		"gpi",
		peek(gp.goto_preview_implementation, "textDocument/implementation"),
		{ desc = "Peek implementation" }
	)
	map(
		"n",
		"gpt",
		peek(gp.goto_preview_type_definition, "textDocument/typeDefinition"),
		{ desc = "Peek type definition" }
	)
	map("n", "gpr", peek(gp.goto_preview_references, "textDocument/references"), { desc = "Peek references" })
	map("n", "gpc", gp.close_all_win, { desc = "Close all peek windows" })
end

M.setup()
return M
