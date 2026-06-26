local map = vim.keymap.set

-- [ The "Double Space" & Project Search ]
map("n", "<leader><leader>", "<cmd>Telescope find_files<CR>", { desc = "Fuzzy find files" })
map("n", "<leader>p", "<cmd>Telescope live_grep<CR>", { desc = "Live grep project" })
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "Find buffers" })
map("n", "<leader>gs", "<cmd>Telescope git_status<CR>", { desc = "Git changed files" })

-- [ General ]
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear highlights" })

-- [ Save ] Cmd+S (Ghostty forwards super+s to nvim as <D-s>)
map({ "n", "i", "v", "s" }, "<D-s>", "<cmd>write<CR>", { desc = "Save file" })

-- [ Buffers ]
map("n", "L", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "H", "<cmd>bprevious<CR>", { desc = "Previous buffer" })

-- [ Clipboard ]
map({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank to system" })
map("n", "<leader>v", '"+p', { desc = "Paste from system" })
map("x", "<leader>P", [["_dP]], { desc = "Paste and keep yank" })

-- [ Deletion ]
map({ "n", "v" }, "<leader>x", '"_d', { desc = "Black hole delete" })

-- [ Editing ]
map("n", "<leader>D", "yyp", { desc = "Duplicate line" })
map("v", "<leader>D", "yP", { desc = "Duplicate selection" })
map("n", "<leader>o", function()
	vim.fn.append(vim.fn.line("."), vim.fn["repeat"]({ "" }, vim.v.count1))
end, { desc = "Blank line(s) below" })
map("n", "<leader>O", function()
	vim.fn.append(vim.fn.line(".") - 1, vim.fn["repeat"]({ "" }, vim.v.count1))
end, { desc = "Blank line(s) above" })

-- [ Smart Home ]
map("n", "<Home>", function()
	local col = vim.fn.col(".")
	local first_nonblank = vim.fn.indent(vim.fn.line(".")) + 1
	return col == first_nonblank and "0" or "^"
end, { expr = true, desc = "Smart Home" })

return {}
