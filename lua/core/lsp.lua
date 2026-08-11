local M = {}

-- Global npm packages live under the *active* node version, so nvm switching (or
-- `default -> 22` following a newer 22.x) silently moves them. Resolve the path
-- from the node on PATH instead of hardcoding a version: a stale hardcoded path
-- means TS loses its tsdk, no client attaches, and goto-preview (gpd/gpr) only
-- reports "not supported by any server" -- invisible behind cmdheight=0.
local function npm_global(pkg)
	local node = vim.fn.exepath("node")
	if node == "" then
		return nil
	end
	local path = vim.fs.joinpath(vim.fn.fnamemodify(node, ":h:h"), "lib", "node_modules", pkg)
	return vim.uv.fs_stat(path) and path or nil
end

-- How to reinstall each server, so a missing one is a keystroke to fix rather than
-- a hunt through shell history. npm globals are per-node-version, so bumping node
-- orphans all of them at once -- see :LspInstallMissing.
local install = {
	vtsls = { exe = "vtsls", npm = { "@vtsls/language-server", "typescript", "typescript-svelte-plugin" } },
	svelte = { exe = "svelteserver", npm = { "svelte-language-server" } },
	angularls = { exe = "ngserver", npm = { "@angular/language-server" } },
	gopls = { exe = "gopls", cmd = { "go", "install", "golang.org/x/tools/gopls@latest" } },
}

local missing = {}

-- Skip vim.lsp.enable() for servers whose executable is missing, and say so once
-- at startup, rather than failing silently on every LSP request.
local function enable_if_installed(server)
	if vim.fn.executable(install[server].exe) == 1 then
		vim.lsp.enable(server)
		return true
	end
	table.insert(missing, server)
	return false
end

local function run(cmd, on_done)
	vim.notify("Running: " .. table.concat(cmd, " "), vim.log.levels.INFO, { title = "LSP install" })
	vim.system(cmd, { text = true }, function(res)
		vim.schedule(function()
			if res.code == 0 then
				vim.notify(cmd[1] .. " finished", vim.log.levels.INFO, { title = "LSP install" })
			else
				vim.notify(
					("%s failed (exit %d)\n%s"):format(cmd[1], res.code, vim.trim(res.stderr or res.stdout or "")),
					vim.log.levels.ERROR,
					{ title = "LSP install" }
				)
			end
			on_done(res.code == 0)
		end)
	end)
end

-- Reinstall whatever is missing for the *currently active* node/go toolchain.
local function install_missing()
	if #missing == 0 then
		return vim.notify("All configured LSP servers are installed", vim.log.levels.INFO, { title = "LSP install" })
	end

	local npm, cmds = {}, {}
	for _, server in ipairs(missing) do
		vim.list_extend(npm, install[server].npm or {})
		if install[server].cmd then
			table.insert(cmds, install[server].cmd)
		end
	end
	if #npm > 0 then
		table.insert(cmds, vim.list_extend({ "npm", "install", "-g" }, npm))
	end

	-- Run sequentially so npm and go don't interleave their output, and keep going
	-- after a failure so one broken server doesn't block the rest.
	local i, all_ok = 0, true
	local function next_cmd(ok)
		all_ok = all_ok and ok ~= false
		i = i + 1
		if cmds[i] then
			return run(cmds[i], next_cmd)
		end
		if all_ok then
			vim.notify("Done -- :restart to attach", vim.log.levels.INFO, { title = "LSP install" })
		else
			vim.notify("Finished with errors -- see :LspInstallMissing output above", vim.log.levels.WARN, {
				title = "LSP install",
			})
		end
	end
	next_cmd()
end

local function report_missing()
	vim.api.nvim_create_user_command("LspInstallMissing", install_missing, {
		desc = "Install LSP servers missing from the current toolchain",
	})
	if #missing == 0 then
		return
	end
	vim.schedule(function()
		vim.notify(
			("Disabled (executable not found): %s\nnode: %s\nRun :LspInstallMissing to reinstall"):format(
				table.concat(missing, ", "),
				vim.fn.exepath("node") ~= "" and vim.fn.exepath("node") or "not found"
			),
			vim.log.levels.WARN,
			{ title = "LSP" }
		)
	end)
end

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
	local svelte_plugin = npm_global("typescript-svelte-plugin")
	local typescript = npm_global("typescript")

	vim.lsp.config("vtsls", {
		settings = {
			vtsls = {
				tsserver = {
					globalPlugins = svelte_plugin and {
						{
							name = "typescript-svelte-plugin",
							location = svelte_plugin,
							enableForWorkspaceTypeScriptVersions = true,
						},
					} or nil,
				},
			},
			typescript = {
				tsdk = typescript and vim.fs.joinpath(typescript, "lib") or nil,
				updateImportsOnFileMove = { enabled = "always" },
				inlayHints = {
					parameterNames = { enabled = "all" },
					variableTypes = { enabled = true },
				},
			},
		},
	})
	-- Requires: npm install -g @vtsls/language-server typescript typescript-svelte-plugin
	enable_if_installed("vtsls")

	vim.lsp.config("svelte", {})
	-- Requires: npm install -g svelte-language-server
	enable_if_installed("svelte")

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
	enable_if_installed("angularls")

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
	enable_if_installed("gopls")

	report_missing()

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
