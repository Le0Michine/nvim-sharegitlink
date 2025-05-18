local utils = require("sharegitlink.utils")

--- @class LinkBuilderOptions
--- @field repo string         Repository name, might include "/"
--- @field commit string       Current commit hash
--- @field rel_path string     Relative path to the file
--- @field start_line number   First selected line number
--- @field end_line number     Last selected line number, could be the same as start_line

--- @class ShareGitLinkConfig
--- @field link_builder fun(opts: LinkBuilderOptions): string   Overrides link building behavior, gets details about repo, commit, rel_path and line numbers then returns a link as string. Default builder produces GitHub links.
--- @field display_link boolean                                When true generated link will appear as virtual text in the last selected line (default: true)

--- @type ShareGitLinkConfig
local config = {
	link_builder = utils.default_link_builder,
	display_link = true,
}

local ShareGitLink = {}

--- Generates link for current buffer in gitfarm
function ShareGitLink.get_gitfarm_link()
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
	local commit = utils.get_commit_hash() or ""

	-- Extract project name from remote URL (supports https and ssh)
	local package_name = utils.extract_repo_path(remote_url)
	-- local start_line, end_line = get_visual_range()
	local start_line, end_line = utils.get_visual_range()

	local url = config.link_builder({
		repo = package_name,
		commit = commit,
		rel_path = rel_path,
		start_line = start_line,
		end_line = end_line,
	})

	return url
end

--- Generates link for current buffer in gitfarm and copies it into clipboard
function ShareGitLink.copy_gitfarm_link()
	local url = ShareGitLink.get_gitfarm_link()
	local _, end_line = utils.get_visual_range()

	vim.fn.setreg("+", url)

	if config.display_link then
		utils.show_virtual_text("GitFarm URL copied to clipboard: " .. url, end_line)
	end
end

--- Generates and opens link for current buffer in gitfarm
function ShareGitLink.open_gitfarm_link()
	local url = ShareGitLink.get_gitfarm_link()

	utils.open_in_browser(url)
end

--- Setup ShareGitLink plugin
--- @param opts ShareGitLinkConfig
--- @usage
--- require("sharegitlink").setup({
---  link_builder = function(opts) return "https://..." end
---  display_link = true,
--- })
function ShareGitLink.setup(opts)
	if opts then
		config.link_builder = opts.link_builder or utils.default_link_builder
		config.display_link = opts.display_link or true
	end
end

return ShareGitLink
