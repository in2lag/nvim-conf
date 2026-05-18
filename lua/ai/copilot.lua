local M = {}

function M.setup()
	require("copilot").setup({
		suggestion = {
			enabled = true,
			auto_trigger = true,
			hide_during_completion = false,
			keymap = {
				accept = "<M-l>",
				accept_word = "<M-Right>",
				accept_line = false,
				next = "<M-]>",
				prev = "<M-[>",
				dismiss = "<C-]>",
			},
		},
		panel = { enabled = false },
		filetypes = {
			["*"] = true,
			gitcommit = false,
			gitrebase = false,
			help = false,
		},
	})
end

vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function(args)
		vim.keymap.set("i", "<Tab>", function()
			local ok, copilot = pcall(require, "copilot.suggestion")
			if ok and copilot.is_visible() then
				copilot.accept()
				return ""
			end
			return "\t"
		end, { buffer = args.buf, expr = true, desc = "Accept Copilot or insert Tab" })
	end,
})

M.setup()
return M
