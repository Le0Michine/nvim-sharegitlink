local utils = require("sharegitlink.utils")

local config = {
	link_builder = utils.default_link_builder,
	display_link = true,
}

local ShareGitLink = {}

function ShareGitLink.copy_gitfarm_link()
	local target_path
	if utils.is_directory_buffer() then
		-- Tree mode: resolve path under cursor
		target_path = utils.get_selected_tree_path()
	else
		-- Normal buffer
		target_path = vim.api.nvim_buf_get_name(0)
	end

	local git_root = utils.get_git_root()
	if not git_root then
		print("Error: not inside a Git repository")
		return
	end
	local rel_path = target_path:sub(#git_root + 2)
	local remote_url = utils.get_git_remote()
	local commit = utils.get_commit_hash()

	-- Extract project name from remote URL (supports https and ssh)
	local package_name = utils.extract_repo_path(remote_url)
	-- local start_line, end_line = get_visual_range()
	local line_fragment = ""
	local start_line, end_line = utils.get_visual_range()
	if not utils.is_directory_buffer() then
		line_fragment = (start_line == end_line) and ("#L" .. start_line) or ("#L" .. start_line .. "-L" .. end_line)
	end

	local url = config.link_builder({
		repo = package_name,
		commit = commit,
		rel_path = rel_path,
		start_line = start_line,
		end_line = end_line,
	})

	vim.fn.setreg("+", url)
	if config.display_link then
		utils.show_virtual_text("GitFarm URL copied to clipboard: " .. url, end_line)
	end
end

function ShareGitLink.setup(opts)
	if opts then
		config.link_builder = opts.link_builde or utils.default_link_builder
		config.display_link = opts.display_link or true
	end
end

return ShareGitLink
