local a = vim.api
local gui = require("godot.debugger.gui")
local cli = require("godot.debugger.cli")
local M = {}

-------------------------------------------------------------------
-- defaults
local config = {
	bin = "godot",
	cli = {},
	gui = {},
}
-------------------------------------------------------------------
-- setup
M.setup = function(opt)
	config = vim.tbl_deep_extend("force", config, opt)

	cli.setup(config.cli)
	gui.setup(config.gui)
	cli.on_debug_exit = function()
		gui.close_gui()
	end
	cli.on_debug_enter = function()
		cli.request({ "mv", "lv", "bt", "gv" }, function()
			gui.open_watcher()
			gui.print_watcher(cli.command_output)
			gui.jump_cursor(cli.command_output["bt"][1])
		end)
	end
	cli.on_log_update = gui.print_console
end
-------------------------------------------------------------------
-- debug at cursor
M.debug_at_cursor = function()
	local line = a.nvim_win_get_cursor(a.nvim_get_current_win())[1]
	local file = vim.fn.expand("%")

	if not string.find(file, ".gd") then
		do
			print("cannot debug at cursor of none gdscript file")
			return
		end
	end
	local cmd = config.bin .. " -d -b res://" .. file .. ":" .. line

	--debug
	--local cmd = "godot -d -b res://addons/lommix_infinite_worlds/nodes/auto_tilemap.gd:67"
	--local cmd = "godot -d"
	gui.open_console()
	cli.spawn(cmd)
end
-------------------------------------------------------------------
-- quit
M.quit = function()
	gui.close_gui()
	cli.prompt:shutdown()
end
-------------------------------------------------------------------
-- step
M.step = function()
	cli.request({ "s", "mv", "lv", "bt", "gv" }, function()
		gui.print_watcher(cli.command_output)
		gui.jump_cursor(cli.command_output["bt"][1])
	end)
end
-------------------------------------------------------------------
-- continue
M.continue = function()
	cli.request("c")
	gui.close_watcher()
end

-------------------------------------------------------------------
-- debug
M.debug = function()
	local cmd = config.bin .. " -d"
	gui.open_console()
	cli.spawn(cmd)
end
return M
