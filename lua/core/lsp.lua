local M = {}

local function go_module_prefix(root)
	if not root then
		return nil
	end
	local gomod = vim.fs.find("go.mod", { upward = true, path = root, type = "file" })[1]
	if not gomod then
		return nil
	end
	for line in io.lines(gomod) do
		local mod = line:match("^module%s+(%S+)")
		if mod then
			return mod
		end
	end
end

function M.setup()
	vim.lsp.config("vtsls", {
		settings = {
			typescript = {
				updateImportsOnFileMove = { enabled = "always" },
				inlayHints = {
					parameterNames = { enabled = "all" },
					variableTypes = { enabled = true },
				},
			},
		},
	})
	vim.lsp.enable("vtsls")

	vim.lsp.config("gopls", {
		before_init = function(_, config)
			local prefix = go_module_prefix(config.root_dir)
			if prefix then
				config.settings = vim.tbl_deep_extend("force", config.settings or {}, {
					gopls = { ["local"] = prefix },
				})
			end
		end,
		settings = {
			gopls = {
				usePlaceholders = true,
				staticcheck = true,
				analyses = {
					unusedparams = true,
					unusedwrite = true,
					nilness = true,
					shadow = true,
				},
				hints = {
					assignVariableTypes = true,
					compositeLiteralFields = true,
					constantValues = true,
					functionTypeParameters = true,
					parameterNames = true,
					rangeVariableTypes = true,
				},
			},
		},
	})
	vim.lsp.enable("gopls")
end

M.setup()
return M
