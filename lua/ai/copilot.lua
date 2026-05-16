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

M.setup()
return M
