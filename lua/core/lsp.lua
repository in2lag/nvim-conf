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
			vtsls = {
				tsserver = {
					globalPlugins = {
						{
							name = "typescript-svelte-plugin",
							location = "/Users/petrprchal/.nvm/versions/node/v22.15.0/lib/node_modules/typescript-svelte-plugin",
							enableForWorkspaceTypeScriptVersions = true,
						},
					},
				},
			},
			typescript = {
				tsdk = "/Users/petrprchal/.nvm/versions/node/v22.15.0/lib/node_modules/typescript/lib",
				updateImportsOnFileMove = { enabled = "always" },
				inlayHints = {
					parameterNames = { enabled = "all" },
					variableTypes = { enabled = true },
				},
			},
		},
	})
	vim.lsp.enable("vtsls")

	vim.lsp.config("svelte", {})
	vim.lsp.enable("svelte")

	-- Angular template intellisense: completion, go-to-definition and
	-- find-references for variables/bindings inside .html / .component.html
	-- templates. Restricted to template filetypes so it does NOT also attach to
	-- .ts files -- otherwise vtsls + angularls both attach and the duplicate
	-- clients double completions/diagnostics and break goto-preview (gpr).
	-- The server still reads the whole .ts project from disk for template smarts.
	-- Requires: npm install -g @angular/language-server
	vim.lsp.config("angularls", {
		filetypes = { "html", "htmlangular" },
	})
	vim.lsp.enable("angularls")

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

	local highlight_group = vim.api.nvim_create_augroup("lsp-document-highlight", { clear = false })
	vim.api.nvim_create_autocmd("LspAttach", {
		callback = function(args)
			local client = vim.lsp.get_client_by_id(args.data.client_id)
			if not client or not client:supports_method("textDocument/documentHighlight") then
				return
			end
			vim.api.nvim_clear_autocmds({ group = highlight_group, buffer = args.buf })
			vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
				group = highlight_group,
				buffer = args.buf,
				callback = vim.lsp.buf.document_highlight,
			})
			vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
				group = highlight_group,
				buffer = args.buf,
				callback = vim.lsp.buf.clear_references,
			})
		end,
	})
	vim.api.nvim_create_autocmd("LspDetach", {
		group = vim.api.nvim_create_augroup("lsp-document-highlight-detach", { clear = true }),
		callback = function(args)
			vim.lsp.buf.clear_references()
			vim.api.nvim_clear_autocmds({ group = highlight_group, buffer = args.buf })
		end,
	})
end

M.setup()
return M
