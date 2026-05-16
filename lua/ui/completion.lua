local M = {}

function M.setup()
	vim.opt.infercase = true
	vim.opt.pumheight = 10

	require("blink.cmp").setup({
		keymap = {
			preset = "default",
			["<Tab>"] = {
				"select_and_accept",
				"snippet_forward",
				function()
					local ok, copilot = pcall(require, "copilot.suggestion")
					if ok and copilot.is_visible() then
						copilot.accept()
						return true
					end
				end,
				"fallback",
			},
			["<S-Tab>"] = { "snippet_backward", "select_prev", "fallback" },
			["<Esc>"] = { "hide", "fallback" },
			["<CR>"] = { "accept", "fallback" },
		},
		appearance = {
			nerd_font_variant = "mono",
		},
		sources = {
			default = { "lsp", "path", "snippets", "buffer" },
		},
		completion = {
			list = {
				selection = { preselect = true, auto_insert = false },
			},
			documentation = { auto_show = true, auto_show_delay_ms = 200 },
			ghost_text = { enabled = false },
		},
		signature = { enabled = true },
		fuzzy = { implementation = "lua" },
	})
end

M.setup()
return M
