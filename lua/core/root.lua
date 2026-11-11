local M = {}

-- Working directory is the nearest ancestor that contains one of these.
-- A nested list is equal priority (nearest match). Later entries are fallbacks,
-- searched only if nothing earlier matched.
-- nvim-tree follows this through sync_root_with_cwd. auto-session keys off it.
local markers = {
  ".prj-root",
	".git",
}

local function real(path)
	return vim.uv.fs_realpath(path) or vim.fs.normalize(path)
end

local function apply(bufnr)
	if vim.bo[bufnr].buftype ~= "" then
		return
	end
	local root = vim.fs.root(bufnr, markers)
	if not root or real(root) == real(vim.fn.getcwd(-1, -1)) then
		return
	end
	vim.api.nvim_set_current_dir(root)
end

function M.setup()
	local group = vim.api.nvim_create_augroup("ProjectRoot", { clear = true })
	vim.api.nvim_create_autocmd({ "BufEnter", "VimEnter", "SessionLoadPost" }, {
		group = group,
		callback = function(args)
			-- Session files cd on their own. g:SessionLoad stays set through
			-- SessionLoadPost, so that event is the one that may correct it.
			if args.event ~= "SessionLoadPost" and vim.g.SessionLoad == 1 then
				return
			end
			apply(args.buf)
		end,
	})
end

M.setup()
return M
