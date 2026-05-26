local M = {}

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
		update_in_insert = true,
		float = {
			border = "rounded",
			source = true,
			header = "",
		},
	})

	local map = vim.keymap.set
	map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line diagnostics" })
	map("n", "<leader>cq", "<cmd>Telescope diagnostics<CR>", { desc = "Project diagnostics" })
end

M.setup()
return M
