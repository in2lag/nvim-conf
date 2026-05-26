local M = {}

function M.setup()
	local indentscope = require("mini.indentscope")
	indentscope.setup({
		symbol = "┊",
		options = { try_as_border = true },
		draw = {
			delay = 50,
			animation = indentscope.gen_animation.linear({ duration = 80, unit = "total" }),
		},
	})

	vim.api.nvim_create_autocmd("FileType", {
		pattern = { "NvimTree", "help", "markdown", "terminal", "DiffviewFiles", "DiffviewFileHistory" },
		callback = function()
			vim.b.miniindentscope_disable = true
		end,
	})

	local function apply_hl()
		vim.api.nvim_set_hl(0, "MiniIndentscopeSymbol", { fg = "#82768e" })
	end
	apply_hl()
	vim.api.nvim_create_autocmd("ColorScheme", {
		group = vim.api.nvim_create_augroup("MiniIndentscopeHL", { clear = true }),
		callback = apply_hl,
	})
end

M.setup()
return M
