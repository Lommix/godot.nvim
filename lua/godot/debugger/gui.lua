local M = {}

local a = vim.api
local watcher_buffer = nil
local watcher_window = nil
local console_buffer = nil
local console_window = nil
local code_window = nil

local watcher_locals = {}
local watcher_globals = {}
local watcher_memebers = {}
local watcher_trace = {}
local console_line_counter = 0
-------------------------------------------------------------------
local config = {}
-------------------------------------------------------------------
-- setup
M.setup = function(opts)
	config = opts
	code_window = a.nvim_get_current_win()
end
-------------------------------------------------------------------
-- close/open
M.open_console = function()
	console_buffer = vim.api.nvim_create_buf(false, true)
	console_window = a.nvim_open_win(console_buffer, false, config.gui.console_config)
	a.nvim_set_current_win(code_window)
end

M.close_console = function()
	if console_buffer then
		a.nvim_buf_delete(console_buffer, { force = true })
		console_buffer = nil
		console_window = nil
		console_line_counter = 0
	end
end
M.open_watcher = function()
	a.nvim_set_current_win(code_window)
	vim.cmd("vsplit")
	watcher_buffer = vim.api.nvim_create_buf(false, true)
	watcher_window = a.nvim_get_current_win()
	a.nvim_win_set_buf(watcher_window, watcher_buffer)
end
M.close_watcher = function()
	if watcher_buffer then
		a.nvim_buf_delete(watcher_buffer, { force = true })
		watcher_buffer = nil
		watcher_window = nil
	end
end
-------------------------------------------------------------------
-- build watcher
-------------------------------------------------------------------
M.set_trace = function(trace)
	watcher_trace = trace
	for _, line in pairs(trace) do
		if string.find(line, "*Frame.+res://") then
			M.jump_cursor(line)
		end
	end
end
M.set_globals = function(globals)
	watcher_globals = globals
end
M.set_members = function(members)
	watcher_memebers = members
end
M.set_locals = function(locals)
	watcher_locals = locals
end
-------------------------------------------------------------------
-- jump cursor
-- Todo: check for override
M.jump_cursor = function(trace)
	local file_line = string.gsub(string.match(trace, "res://.+:%d+"), "res://", "")
	local file, line = unpack(vim.split(file_line, ":"))
	a.nvim_set_current_win(code_window)
	vim.cmd("e +" .. line .. " " .. file)
	vim.cmd("normal! zz")
end
-------------------------------------------------------------------
-- print console
M.console_log = function(line)
	if console_buffer and a.nvim_buf_is_valid(console_buffer) and string.len(line) then
		local row = a.nvim_win_get_cursor(console_window)[1]
		a.nvim_buf_set_lines(console_buffer, console_line_counter + 1, console_line_counter + 2, false, { line })
		a.nvim_win_set_cursor(console_window, { console_line_counter + 1, 0 })
		console_line_counter = console_line_counter + 1
	end
end
-------------------------------------------------------------------
-- print watcher
M.print_watcher = function()
	local text = {}

	table.insert(text, "_________________________________________")
	table.insert(text, "-- Godot Debugger 0.11")

	table.insert(text, "")
	table.insert(text, "_________________________________________")
	table.insert(text, "-- global --")
	if watcher_globals then
		for _, line in pairs(watcher_globals) do
			table.insert(text, "#" .. line)
		end
	end
	table.insert(text, "")
	table.insert(text, "_________________________________________")
	table.insert(text, "-- class --")
	if watcher_memebers then
		for _, line in pairs(watcher_memebers) do
			table.insert(text, "#" .. line)
		end
	end
	table.insert(text, "")
	table.insert(text, "_________________________________________")
	table.insert(text, "-- scope --")
	if watcher_locals then
		for _, line in pairs(watcher_locals) do
			table.insert(text, "#" .. line)
		end
	end
	table.insert(text, "")
	table.insert(text, "________________________________________")
	table.insert(text, "-- stack")
	if watcher_trace then
		for _, line in pairs(watcher_trace) do
			table.insert(text, line)
		end
	end

	a.nvim_buf_set_lines(watcher_buffer, 0, -1, true, text)
end

return M
