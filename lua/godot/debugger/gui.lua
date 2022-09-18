local M = {}

local a = vim.api
local watcher_buffer = vim.api.nvim_create_buf(true, true)
local watcher_window = nil
local console_buffer = vim.api.nvim_create_buf(true, true)
local console_window = nil
local code_window = nil
-------------------------------------------------------------------
-- setup
M.setup = function(opts)
	code_window = a.nvim_get_current_win()
end
-------------------------------------------------------------------
-- build console
M.open_console = function()
	console_window = a.nvim_open_win(console_buffer, false, {
		relative = "editor",
		anchor = "SW",
		width = 99999,
		height = 10,
		col = 1,
		row = 99999,
		border = "double",
	})
	a.nvim_set_current_win(code_window)
end
-------------------------------------------------------------------
-- build watcher
M.open_watcher = function()
	vim.cmd("vsplit")
	watcher_window = a.nvim_get_current_win()
	a.nvim_win_set_buf(watcher_window, watcher_buffer)
	a.nvim_set_current_win(code_window)
end
-------------------------------------------------------------------
-- close consle
M.close_console = function ()
	if console_window and a.nvim_win_is_valid(console_window) then
		a.nvim_win_close(console_window, true)
	end
end
-------------------------------------------------------------------
-- close watcher
M.close_watcher = function ()
	if watcher_window and a.nvim_win_is_valid(watcher_window) then
		a.nvim_win_close(watcher_window, true)
	end
end
-------------------------------------------------------------------
-- close gui
M.close_gui = function()
    M.close_watcher()
    M.close_console()
end
-------------------------------------------------------------------
-- jump cursor
M.jump_cursor = function(current_trace)
	local file_line = string.gsub(string.match(current_trace, "res://.+:%d+"), "res://", "")
	local file, line = unpack(vim.split(file_line, ":"))
	a.nvim_set_current_win(code_window)
	vim.cmd("e +" .. line .. " " .. file)
	vim.cmd("normal! zz")
end
-------------------------------------------------------------------
-- print console
M.print_console = function(line)
	if console_window and a.nvim_win_is_valid(console_window)then
		local row = a.nvim_win_get_cursor(console_window)[1]
		a.nvim_buf_set_lines(console_buffer, row + 1, row + 2, false, { line })
		a.nvim_win_set_cursor(console_window, { row + 1, 0 })
	end
end
-------------------------------------------------------------------
-- print watcher
M.print_watcher = function(command_output)
	local text = {}

	table.insert(text, "_________________________________________")
	table.insert(text, "-- Godot Debugger 0.11")

	table.insert(text, "")
	table.insert(text, "_________________________________________")
	table.insert(text, "-- global --")
	if command_output["gv"] then
		for _, line in pairs(command_output["gv"]) do
			table.insert(text, "#" .. line)
		end
	end
	table.insert(text, "")
	table.insert(text, "_________________________________________")
	table.insert(text, "-- class --")
	if command_output["mv"] then
		for _, line in pairs(command_output["mv"]) do
			table.insert(text, "#" .. line)
		end
	end
	table.insert(text, "")
	table.insert(text, "_________________________________________")
	table.insert(text, "-- current scope --")
	if command_output["lv"] then
		for _, line in pairs(command_output["lv"]) do
			table.insert(text, "#" .. line)
		end
	end
	table.insert(text, "")
	table.insert(text, "________________________________________")
	table.insert(text, "-- Stack")
	if command_output["bt"] then
		for _, line in pairs(command_output["bt"]) do
			table.insert(text, line)
		end
	end

	a.nvim_buf_set_lines(watcher_buffer, 0, -1, true, text)
end

return M
