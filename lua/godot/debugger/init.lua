local gui = require("godot.debugger.gui")
local godot_job = require("godot.debugger.job")
local M = {}
local current_job = nil
local debug_mode = false
-------------------------------------------------------------------
-- defaults
local config = {}
-------------------------------------------------------------------
-- setup
M.setup = function(opts)
	config = opts
	gui.setup(config)
end
-------------------------------------------------------------------
local on_log = function(line)
	gui.console_log(line)
end
-------------------------------------------------------------------
local reload_watcher = function()
	godot_job:request("gv", function(response)
		gui.set_globals(response)
	end)
	godot_job:request("mv", function(response)
		gui.set_members(response)
	end)
	godot_job:request("lv", function(response)
		gui.set_locals(response)
	end)
	godot_job:request("bt", function(response)
		gui.set_trace(response)
		gui.print_watcher()
	end)
end
-------------------------------------------------------------------
local on_enter_debug = function()
	gui.open_watcher()
	reload_watcher()
end

local start_job = function(command, cwd)
	debug_mode = false
	current_job = godot_job:new({
		cmd = command,
		cwd = cwd,
		on_log = function(line)
			on_log(line)
		end,
		on_break = function()
			if not debug_mode then
				on_enter_debug()
			end
			debug_mode = true
		end,
		on_exit = function()
			gui.close_console()
			gui.close_watcher()
		end,
	})
end
-------------------------------------------------------------------
-- debug at cursor
M.debug_at_cursor = function()
	local line = vim.api.nvim_win_get_cursor(vim.api.nvim_get_current_win())[1]
	local file = vim.fn.expand("%")
	if not string.find(file, ".gd") then
		do
			print("this action requires gdscript")
			return
		end
	end

	if current_job then
		current_job:shutdown()
	end

	local command = {
		config.bin,
		"-d",
		"-b",
		"res://" .. file .. ":" .. line,
	}
	local cwd = vim.fn.getcwd()
	gui.open_console()
	start_job(command, cwd)
end
-------------------------------------------------------------------
-- quit
M.quit = function()
	current_job:shutdown()
end
-------------------------------------------------------------------
-- step
M.step = function()
	current_job:request("s", function(response)
		for _, line in pairs(response) do
			if string.find(line, "Debugger Break,") then
				break
			end
			gui.console_log(line)
		end
		reload_watcher()
	end)
end
-------------------------------------------------------------------
-- continue
M.continue = function()
	gui.close_watcher()
	current_job:request("c", function()
		on_enter_debug()
	end)
end
-------------------------------------------------------------------
-- debug
M.debug = function()
	if current_job then
		current_job:shutdown()
	end

	local command = {
		config.bin,
		"-d",
	}
	local cwd = vim.fn.getcwd()
	gui.open_console()
	start_job(command, cwd)
end

return M
