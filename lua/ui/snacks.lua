local M = {}

-- Snacks.setup() may only be called ONCE -- a second call hard-errors with
-- "snacks.nvim is already setup" and silently drops that config. So every snacks
-- module (picker, notifier, ...) is configured here, and the feature modules
-- (ui/search.lua, ui/git.lua, ...) only *use* the Snacks global.
-- This module must therefore load before any of them.
function M.setup()
	local exclude = {
		".git",
		-- Image files
		"*.png", "*.jpg", "*.jpeg", "*.gif", "*.bmp", "*.webp",
		"*.svg", "*.ico", "*.tif", "*.tiff", "*.heic", "*.avif",
	}

	require("snacks").setup({
		picker = {
			sources = {
				files = { hidden = true, exclude = exclude },
				grep = { hidden = true, exclude = exclude },
			},
		},
		-- cmdheight=0 (core/options.lua) leaves nowhere to draw messages, so any
		-- vim.notify used to force a "press ENTER to continue" prompt that hid the
		-- text -- e.g. a missing LSP server showed up as an unreadable blip.
		-- Route them to floating toasts instead; history keeps ones that time out.
		notifier = {
			timeout = 4000,
			style = "compact",
			top_down = false,
			margin = { top = 0, right = 1, bottom = 1 },
		},
	})

	local map = vim.keymap.set
	map("n", "<leader>nh", function()
		Snacks.notifier.show_history()
	end, { desc = "Notification history" })
	map("n", "<leader>nd", function()
		Snacks.notifier.hide()
	end, { desc = "Dismiss notifications" })
end

M.setup()
return M
