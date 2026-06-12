local M = {}

-- Path to Microsoft's vscode-js-debug (installed manually, see install notes).
local js_debug = vim.fn.expand("~/.local/share/nvim/js-debug/src/dapDebugServer.js")

local function setup_signs()
	vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError", linehl = "", numhl = "" })
	vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticWarn", linehl = "", numhl = "" })
	vim.fn.sign_define("DapLogPoint", { text = "◆", texthl = "DiagnosticInfo", linehl = "", numhl = "" })
	vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticOk", linehl = "Visual", numhl = "" })
	vim.fn.sign_define("DapBreakpointRejected", { text = "●", texthl = "Comment", linehl = "", numhl = "" })
end

local function setup_ui(dap)
	local dapui = require("dapui")
	dapui.setup()
	require("nvim-dap-virtual-text").setup({})

	dap.listeners.before.attach.dapui_config = function()
		dapui.open()
	end
	dap.listeners.before.launch.dapui_config = function()
		dapui.open()
	end
	dap.listeners.before.event_terminated.dapui_config = function()
		dapui.close()
	end
	dap.listeners.before.event_exited.dapui_config = function()
		dapui.close()
	end
end

local function setup_go()
	-- Wraps Delve (dlv). Provides debug-nearest-test, debug-main, attach.
	require("dap-go").setup()
end

local function setup_js(dap)
	for _, adapter in ipairs({ "pwa-node", "pwa-chrome" }) do
		dap.adapters[adapter] = {
			type = "server",
			host = "localhost",
			port = "${port}",
			executable = {
				command = "node",
				args = { js_debug, "${port}" },
			},
		}
	end

	local function configs(filetype)
		local list = {
			{
				type = "pwa-node",
				request = "launch",
				name = "Launch current file (Node)",
				program = "${file}",
				cwd = "${workspaceFolder}",
				sourceMaps = true,
			},
			{
				type = "pwa-node",
				request = "attach",
				name = "Attach to process",
				processId = require("dap.utils").pick_process,
				cwd = "${workspaceFolder}",
				sourceMaps = true,
			},
		}
		-- Browser debugging (Svelte / Vite dev server defaults to 5173).
		table.insert(list, {
			type = "pwa-chrome",
			request = "launch",
			name = "Launch Chrome against localhost:5173",
			url = "http://localhost:5173",
			webRoot = "${workspaceFolder}",
			sourceMaps = true,
		})
		dap.configurations[filetype] = list
	end

	for _, ft in ipairs({ "javascript", "typescript", "javascriptreact", "typescriptreact", "svelte" }) do
		configs(ft)
	end
end

local function setup_keymaps(dap)
	local dapui = require("dapui")
	local map = vim.keymap.set

	map("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
	map("n", "<leader>dB", function()
		dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
	end, { desc = "Conditional breakpoint" })
	map("n", "<leader>dc", dap.continue, { desc = "Continue / start" })
	map("n", "<leader>do", dap.step_over, { desc = "Step over" })
	map("n", "<leader>di", dap.step_into, { desc = "Step into" })
	map("n", "<leader>dO", dap.step_out, { desc = "Step out" })
	map("n", "<leader>dl", dap.run_last, { desc = "Run last" })
	map("n", "<leader>dr", dap.repl.toggle, { desc = "Toggle REPL" })
	map("n", "<leader>du", dapui.toggle, { desc = "Toggle DAP UI" })
	map({ "n", "v" }, "<leader>de", dapui.eval, { desc = "Evaluate expression" })
	map("n", "<leader>dq", dap.terminate, { desc = "Terminate session" })
	map("n", "<leader>dt", function()
		require("dap-go").debug_test()
	end, { desc = "Debug nearest Go test" })
end

function M.setup()
	local ok, dap = pcall(require, "dap")
	if not ok then
		return
	end

	setup_signs()
	setup_ui(dap)
	setup_go()
	setup_js(dap)
	setup_keymaps(dap)
end

M.setup()
return M
