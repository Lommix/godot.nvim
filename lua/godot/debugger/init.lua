local a = vim.api

local M = {
	watcher_buffer = vim.api.nvim_create_buf(true, true),
	watcher_window = nil,
	console_buffer = vim.api.nvim_create_buf(true, true),
	console_window = nil,
	code_window = nil,
	cli = require("godot.debugger.cli"),
	gui_build,
	gui_close,
	debug,
	debug_at_cursor,
	setup,
	quit,
	step,
}

-------------------------------------------------------------------
-- build gui
M.gui_build = function()
	M.code_window = a.nvim_get_current_win()
	vim.cmd("vsplit")
	M.watcher_window = a.nvim_get_current_win()
	a.nvim_win_set_buf(M.watcher_window, M.watcher_buffer)
	-- console log
	M.console_window = a.nvim_open_win(M.console_buffer, false, {
		relative = "editor",
		anchor = "SW",
		width = 99999,
		height = 10,
		col = 1,
		row = 99999,
		border = "double",
	})
	a.nvim_set_current_win(M.code_window)
end

-------------------------------------------------------------------
-- setup
M.setup = function()
	M.cli.setup()
	M.cli.on_debug_exit = function()
		M.gui_close()
	end
	M.cli.on_debug_enter = function()
		--M.cli.request('mv', function ()
		--local content = vim.tbl_flatten(m.cli.command_output)
		--a.nvim_buf_set_lines(m.watcher_buffer, 0, -1, true, content)
		--end)
	end
end

-------------------------------------------------------------------
-- gui close
M.gui_close = function()
	a.nvim_win_close(M.watcher_window, true)
	a.nvim_win_close(M.console_window, true)
end

-------------------------------------------------------------------
-- debug at cursor
M.debug_at_cursor = function()
	local cmd = "godot -d -b res://addons/lommix_infinite_worlds/nodes/auto_tilemap.gd:67"
	M.gui_build()
	M.cli.prompt:send(cmd)
end

M.quit = function()
	M.cli.request("q", function()
		M.gui_close()
	end)
end

M.step = function()
	M.cli.request("s", function()
		M.gui_close()
		local content = vim.tbl_flatten(M.cli.command_output)
		a.nvim_buf_set_lines(M.watcher_buffer, 0, -1, true, content)
	end)
end
-------------------------------------------------------------------
-- debug
M.debug = function() end
return M
