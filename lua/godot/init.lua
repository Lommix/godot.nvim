local M = {}
-------------------------------------------------------------------
M.debugger = require("godot.debugger")
-------------------------------------------------------------------
-- default config
local config = {
	bin = "godot",
	gui = {
		console_config = {
			relative = "editor",
			anchor = "SW",
			width = 99999,
			height = 10,
			col = 1,
			row = 99999,
			border = "double",
		},
	},
}
-------------------------------------------------------------------
-- setup
-- @param opts : see above
M.setup = function(opts)
	config = vim.tbl_deep_extend("force", config, opts or {})
	M.debugger.setup(config)

    vim.api.nvim_create_user_command("GodotDebug", M.debugger.debug, {})
    vim.api.nvim_create_user_command("GodotBreakAtCursor", M.debugger.debug_at_cursor, {})
    vim.api.nvim_create_user_command("GodotStep", M.debugger.step, {})
    vim.api.nvim_create_user_command("GodotQuit", M.debugger.quit,{})
    vim.api.nvim_create_user_command("GodotContinue", M.debugger.continue,{})
end

M.setup()

-- reload on run for debug stuff
return M
