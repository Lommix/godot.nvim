local M = {}
-------------------------------------------------------------------
M.debugger = require("godot.debugger")
-------------------------------------------------------------------
-- default config
local config = {
	bin = "godot",
	gui = {
		console_config = {
			anchor = "SW",
			border = "double",
			col = 1,
			height = 10,
			relative = "editor",
			row = 99999,
			style = "minimal",
			width = 99999,
		},
	},
	pipepath = vim.fn.stdpath("cache") .. "/godot.pipe",
}

-- Check if the pipepath is already in the server list
-- @param pipe : path to the pipe
local function is_server_running(pipe)
	local servers = vim.fn.serverlist()
	for _, server in ipairs(servers) do
		if server == pipe then
			return true
		end
	end
	return false
end

-------------------------------------------------------------------
-- setup
-- @param opts : see above
M.setup = function(opts)
	config = vim.tbl_deep_extend("force", config, opts or {})

	-- If the server is running, "serverstart" automatically sets up Neovim to listen on the given pipe
	if not vim.loop.fs_stat(config.pipepath) and not is_server_running(config.pipepath) then
		vim.fn.serverstart(config.pipepath)
	end

	M.debugger.setup(config)

	vim.api.nvim_create_user_command("GodotDebug", M.debugger.debug, {})
	vim.api.nvim_create_user_command("GodotBreakAtCursor", M.debugger.debug_at_cursor, {})
	vim.api.nvim_create_user_command("GodotStep", M.debugger.step, {})
	vim.api.nvim_create_user_command("GodotQuit", M.debugger.quit, {})
	vim.api.nvim_create_user_command("GodotContinue", M.debugger.continue, {})
end

M.setup()

-- reload on run for debug stuff
return M
