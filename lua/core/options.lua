vim.opt.termguicolors = true

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true

vim.opt.list = true
vim.opt.listchars = { tab = "› ", lead = "·", trail = "·", nbsp = "␣" }

vim.opt.title = true
vim.opt.titlestring = "nvim - %{fnamemodify(getcwd(), ':t')}"

vim.opt.signcolumn = "yes"

return {}
