local M = {}

local a = vim.api
local watcher_buffer = vim.api.nvim_create_buf(true, true)
local watcher_window = nil
local console_buffer = vim.api.nvim_create_buf(true, true)
local console_window = nil
local code_window = nil

local watcher_locals = {}
local watcher_globals = {}
local watcher_memebers = {}
local watcher_trace = {}

-------------------------------------------------------------------
local config = {
	console_config = {
		relative = "editor",
		anchor = "SW",
		width = 99999,
		height = 10,
		col = 1,
		row = 99999,
		border = "double",
	},
}

-------------------------------------------------------------------
-- setup
M.setup = function(opts)
	config = vim.tbl_deep_extend("force", config, opts)
	code_window = a.nvim_get_current_win()
end
-------------------------------------------------------------------
-- build console
M.open_console = function()
	console_window = a.nvim_open_win(console_buffer, false, config.console_config)
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
M.close_console = function()
	if console_window and a.nvim_win_is_valid(console_window) then
		a.nvim_win_close(console_window, true)
	end
end
-------------------------------------------------------------------
M.set_trace = function(trace)
	watcher_trace = trace
	if trace[1] then
		M.jump_cursor(trace[1])
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
-- close watcher
M.close_watcher = function()
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
	if console_window and a.nvim_win_is_valid(console_window) and string.len(line) then
		local row = a.nvim_win_get_cursor(console_window)[1]
		a.nvim_buf_set_lines(console_buffer, row + 1, row + 2, false, { line })
		a.nvim_win_set_cursor(console_window, { row + 1, 0 })
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
