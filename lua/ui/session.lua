local M = {}

function M.setup()
	vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal"

	require("auto-session").setup({
		auto_save = true,
		auto_restore = true,
		auto_create = true,
		suppressed_dirs = { "~/", "~/Downloads", "~/Desktop", "/" },
		pre_save_cmds = { "NvimTreeClose" },
	})
end

M.setup()
return M
