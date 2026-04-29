local M = {}

function M.setup()
	require("render-markdown").setup({
		file_types = { "markdown" },
		completions = { lsp = { enabled = true } },
		heading = {
			sign = false,
			icons = {},
			width = "full",
			border = false,
			backgrounds = {},
			foregrounds = {},
		},
		code = {
			sign = false,
			width = "block",
			min_width = 60,
		},
		checkbox = {
			unchecked = { icon = "󰄱 ", highlight = "RenderMarkdownUnchecked" },
			checked = { icon = "󰱒 ", highlight = "RenderMarkdownChecked" },
		},
		bullet = {
			icons = { "●" },
			highlight = {
				"RenderMarkdownBullet1",
				"RenderMarkdownBullet2",
				"RenderMarkdownBullet3",
				"RenderMarkdownBullet4",
			},
		},
		link = { enabled = false },
	})

	local function set_heading_hls()
		local levels = {
			{ "#e78284" },
			{ "#ef9f76" },
			{ "#e5c890" },
			{ "#a6d189" },
			{ "#8caaee" },
			{ "#ca9ee6" },
		}
		for i, c in ipairs(levels) do
			local opts = { fg = c[1], bold = true }
			vim.api.nvim_set_hl(0, "@markup.heading." .. i .. ".markdown", opts)
			vim.api.nvim_set_hl(0, "@markup.heading." .. i, opts)
			vim.api.nvim_set_hl(0, "markdownH" .. i, opts)
		end
		local bullet_colors = { "#8caaee", "#a6d189", "#ef9f76", "#ca9ee6" }
		for i, c in ipairs(bullet_colors) do
			vim.api.nvim_set_hl(0, "RenderMarkdownBullet" .. i, { fg = c })
		end
		vim.api.nvim_set_hl(0, "RenderMarkdownUnchecked", { fg = "#e5c890" })
		vim.api.nvim_set_hl(0, "RenderMarkdownChecked", { fg = "#a6d189" })
		local label_hl = vim.api.nvim_get_hl(0, { name = "@markup.link.label", link = false })
		label_hl.underline = true
		vim.api.nvim_set_hl(0, "@markup.link.label.markdown_inline", label_hl)
	end
	set_heading_hls()
	vim.api.nvim_create_autocmd("ColorScheme", {
		group = vim.api.nvim_create_augroup("RenderMarkdownHeadingHL", { clear = true }),
		callback = set_heading_hls,
	})

	vim.keymap.set("n", "<leader>mp", "<cmd>RenderMarkdown toggle<CR>", { desc = "Toggle Markdown render" })
end

M.setup()
return M
