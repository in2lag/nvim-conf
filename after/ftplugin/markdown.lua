-- Sourced after runtime ftplugin/markdown.vim; FileType autocmds can run too early.
vim.bo.tabstop = 2
vim.bo.shiftwidth = 2
vim.bo.softtabstop = 2
vim.bo.expandtab = true

-- Markdown surrounds (mini.surround): sa{motion}{char}, visual sa{char}, sd/sr{char}
vim.b.minisurround_config = {
	custom_surroundings = {
		B = {
			input = { "%*%*().-()%*%*" },
			output = { left = "**", right = "**" },
		},
		i = {
			input = { "_(.-)_" },
			output = { left = "_", right = "_" },
		},
		s = {
			input = { "~~().-()~~" },
			output = { left = "~~", right = "~~" },
		},
	},
}
