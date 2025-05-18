local utils = require("sharegitlink.utils")

--- @class LinkBuildeOptions
--- @field repo string         Repository name, might include "/"
--- @field commit string       Current commit hash
--- @field rel_path string     Relative path to the file
--- @field start_line number   First selected line number
--- @field end_line number     Last selected line number, could be the same as start_line

--- @class ShareGitLinkConfig
--- @field link_builder fun(opts: LinkBuildeOptions): string   Overrides link building behaviour, gets details about repo, commit, rel_path and line numbers then returns a link as string. Default builder produces GitHub links.
--- @field display_link boolean                                When true generated link will appear as virtual text in the last selected line (default: true)
--- @field open_link boolean                                   When true the plugin will listen for the first keypress on "g" to open the link in the default browser (default: false)

--- @type ShareGitLinkConfig
local config = {
	link_builder = utils.default_link_builder,
	display_link = true,
	open_link = false,
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

	vim.fn.setreg("+", url)
	if config.display_link then
		utils.show_virtual_text("GitFarm URL copied to clipboard: " .. url, end_line)
	end
	if config.open_link then
		utils.open_in_browser(url)
	end
end

--- Setup ShareGitLink plugin
--- @param opts ShareGitLinkConfig
--- @usage
--- require("sharegitlink").setup({
---  link_builder = function(opts) return "https://..." end
---  display_link = true,
---  open_link = true,
--- })
function ShareGitLink.setup(opts)
	if opts then
		config.link_builder = opts.link_builder or utils.default_link_builder
		config.display_link = opts.display_link or true
		config.open_link = opts.open_link or false
	end
end

return ShareGitLink
