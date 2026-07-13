local map = vim.keymap.set

-- [ The "Double Space" & Project Search ]
map("n", "<leader><leader>", function()
	Snacks.picker.smart()
end, { desc = "Smart find files (frecency)" })
map("n", "<leader>p", function()
	Snacks.picker.grep()
end, { desc = "Live grep project" })
map("n", "<leader>fb", function()
	Snacks.picker.buffers()
end, { desc = "Find buffers" })
map("n", "<leader>gs", function()
	Snacks.picker.git_status()
end, { desc = "Git changed files" })
map("n", "<leader>gh", function()
	Snacks.picker.git_diff()
end, { desc = "Git hunks" })
-- In visual mode the browser link targets the selected line range
map({ "n", "x" }, "<leader>go", function()
	Snacks.gitbrowse()
end, { desc = "Open file on remote (git)" })

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
