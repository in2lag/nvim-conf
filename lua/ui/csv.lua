local M = {}

function M.setup()
	require("csvview").setup({
		view = { display_mode = "border" },
		keymaps = {
			textobject_field_inner = { "if", mode = { "o", "x" } },
			textobject_field_outer = { "af", mode = { "o", "x" } },
			jump_next_field_end = { "<Tab>", mode = { "n", "v" } },
			jump_prev_field_end = { "<S-Tab>", mode = { "n", "v" } },
		},
	})

	vim.api.nvim_create_autocmd("FileType", {
		group = vim.api.nvim_create_augroup("CsvViewAuto", { clear = true }),
		pattern = { "csv", "tsv" },
		callback = function(args)
			vim.cmd("CsvViewEnable")
			vim.keymap.set("n", "<leader>mc", "<cmd>CsvViewToggle<CR>", { buffer = args.buf, desc = "Toggle CSV view" })
		end,
	})
end

M.setup()
return M
