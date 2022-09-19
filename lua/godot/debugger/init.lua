local gui = require("godot.debugger.gui")
local cli = require("godot.debugger.cli")
local M = {}

-------------------------------------------------------------------
-- defaults
local config = {
	bin = "godot",
	gui = {
		-- @defaults
		--	console_config = {
		--	    relative = "editor",
		--	   	anchor = "SW",
		--	   	width = 99999,
		--	   	height = 10,
		--	   	col = 1,
		--	   	row = 99999,
		--	   	border = "double",
		--	},
	},
}
-------------------------------------------------------------------
-- setup
M.setup = function(opts)
	config = vim.tbl_deep_extend("force", config, opts)
	gui.setup(config.gui)
end
-------------------------------------------------------------------
local on_log = function(line)
	gui.console_log(line)
end
-------------------------------------------------------------------
local reload_watcher = function()
	cli.request_globals(function(response)
		gui.set_globals(response)
	end)
	cli.request_members(function(response)
		gui.set_members(response)
	end)
	cli.request_locals(function(response)
		gui.set_locals(response)
	end)
	cli.request_trace(function(response)
		gui.set_trace(response)
		gui.print_watcher()
	end)
end
-------------------------------------------------------------------
local on_enter_debug = function()
	gui.open_watcher()
	reload_watcher()
end
-------------------------------------------------------------------
-- debug at cursor
M.debug_at_cursor = function()
	local line = vim.api.nvim_win_get_cursor(vim.api.nvim_get_current_win())[1]
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
	gui.open_console()
	cli.spawn(cmd, on_enter_debug, on_log)
end
-------------------------------------------------------------------
-- quit
M.quit = function()
	cli.quit(function()
		gui.close_gui()
	end)
end
-------------------------------------------------------------------
-- step
M.step = function()
	cli.request_step(function(response)
		for _, line in pairs(response) do
			gui.console_log(line)
		end
		reload_watcher()
	end)
end
-------------------------------------------------------------------
-- continue
M.continue = function()
	gui.close_watcher()
	cli.continue(function()
		gui.open_watcher()
		reload_watcher()
	end)
end

-------------------------------------------------------------------
-- debug
M.debug = function()
	local cmd = config.bin .. " -d"
	gui.open_console()
	cli.spawn(cmd, on_enter_debug, on_log)
end

return M
