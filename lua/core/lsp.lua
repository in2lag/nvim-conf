local M = {}

function M.setup()
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
