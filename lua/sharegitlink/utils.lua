local ns_id = vim.api.nvim_create_namespace("mygitlinker")

local M = {}

local function safe_read_command(cmd_args)
	local cwd = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":p:h")
	local result = vim.system(cmd_args, { cwd = cwd }):wait()
	if result.code ~= 0 then
		return nil
	end
	return vim.fn.trim(result.stdout)
end

function M.get_git_root()
	return safe_read_command({ "git", "rev-parse", "--show-toplevel" })
end

function M.get_git_remote()
	return safe_read_command({ "git", "remote", "get-url", "origin" })
end

function M.get_commit_hash()
	return safe_read_command({ "git", "rev-parse", "HEAD" })
end

function M.is_directory_buffer()
	local name = vim.api.nvim_buf_get_name(0)
	return name ~= "" and vim.fn.isdirectory(name) == 1
end

function M.get_selected_tree_path()
	local cwd = vim.fn.getcwd()
	local target_file = vim.fn.expand("<cfile>")

	if target_file == "" then
		-- fallback to current directory
		return cwd
	end

	local current_directory = vim.api.nvim_buf_get_name(0)

	return vim.fn.resolve(current_directory .. "/" .. target_file)
end

function M.get_visual_range()
	local mode = vim.fn.mode()
	if mode ~= "v" and mode ~= "V" then
		local line = vim.fn.line(".")
		return line, line
	end

	local start_line = vim.fn.line("v")
	local end_line = vim.fn.line(".")
	if start_line > end_line then
		start_line, end_line = end_line, start_line
	end
	return start_line, end_line
end

function M.extract_repo_path(remote_url)
	-- Remove trailing .git
	remote_url = remote_url:gsub("%.git$", "")

	-- SSH format: git@host:owner/repo
	local ssh_path = remote_url:match("git@[^:]+:(.+)")
	if ssh_path then
		return ssh_path
	end

	-- HTTPS format: https://host/owner/repo
	local https_path = remote_url:match("https?://[^/]+/(.+)")
	if https_path then
		return https_path
	end

	-- Fallback: just the last segment (best guess)
	return remote_url:match("([^/]+)$")
end

function M.default_link_builder(opts)
	local url = string.format("https://github.com/%s/blob/%s/%s", opts.repo, opts.commit, opts.rel_path)
	if opts.start_line then
		if opts.end_line and opts.end_line ~= opts.start_line then
			url = url .. string.format("#L%d-L%d", opts.start_line, opts.end_line)
		else
			url = url .. string.format("#L%d", opts.start_line)
		end
	end
	return url
end

function M.show_virtual_text(message, line)
	-- Clear old virtual text
	vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)

	-- Add virtual text at line (0-indexed)
	vim.api.nvim_buf_set_extmark(0, ns_id, line - 1, 0, {
		virt_text = { { "→ " .. message, "Comment" } },
		virt_text_pos = "eol",
	})

	-- Set autocmd to remove on cursor move
	vim.api.nvim_create_autocmd("CursorMoved", {
		buffer = 0,
		once = true,
		callback = function()
			vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
		end,
	})
end

function M.open_in_browser(link)
	vim.keymap.set("n", "<CR>", function()
		local open_cmd
		if vim.fn.has("mac") == 1 then
			open_cmd = { "open", link }
		elseif vim.fn.has("unix") == 1 then
			open_cmd = { "xdg-open", link }
		else
			vim.notify("Cannot open browser on this OS", vim.log.levels.ERROR)
			return
		end

		vim.fn.jobstart(open_cmd, { detach = true })
		vim.keymap.del("n", "<CR>", { buffer = 0 })
	end, { buffer = 0, desc = "Open Git link in browser", nowait = true })

	vim.api.nvim_create_autocmd("CursorMoved", {
		buffer = 0,
		once = true,
		callback = function()
			pcall(vim.keymap.del, "n", "<CR>", { buffer = 0 })
		end,
	})
end

return M

