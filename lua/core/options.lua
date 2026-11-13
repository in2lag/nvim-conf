vim.opt.termguicolors = true

-- runtime/ftplugin/markdown.vim forces 4-space indent when this stays at default (1).
vim.g.markdown_recommended_style = 0

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true

-- Filetype plugins (e.g. python) set shiftwidth to 4; keep Tab at 2 spaces everywhere.
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("indent-2", { clear = true }),
	callback = function()
		vim.bo.tabstop = 2
		vim.bo.shiftwidth = 2
		vim.bo.softtabstop = 2
		vim.bo.expandtab = true
	end,
})

vim.opt.list = true
vim.opt.listchars = { tab = "› ", lead = "·", trail = "·", nbsp = "␣" }

vim.opt.title = true
vim.opt.titlestring = "%{fnamemodify(getcwd(), ':t')} - nvim"

vim.opt.signcolumn = "yes:2"

vim.opt.scrollopt = "ver,jump"

vim.opt.cmdheight = 0

vim.opt.updatetime = 100

vim.opt.startofline = true
return {}
