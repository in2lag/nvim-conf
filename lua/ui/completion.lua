local M = {}

function M.setup()
	vim.opt.infercase = true
	vim.opt.pumheight = 10

	require("blink.cmp").setup({
		keymap = {
			preset = "default",
			["<Tab>"] = {
				function(cmp)
					if cmp.is_visible() then
						cmp.select_next()
						return true
					end
					local ok, copilot = pcall(require, "copilot.suggestion")
					if ok and copilot.is_visible() then
						copilot.accept()
						return true
					end
				end,
				"fallback",
			},
			["<S-Tab>"] = { "select_prev", "fallback" },
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
			documentation = { auto_show = true, auto_show_delay_ms = 200 },
			ghost_text = { enabled = false },
		},
		signature = { enabled = true },
		fuzzy = { implementation = "lua" },
	})
end

M.setup()
return M
