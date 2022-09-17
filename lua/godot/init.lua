local Terminal = require("toggleterm.terminal").Terminal
local plenary = require("plenary")
local a = vim.api
---------------------------------------------------------
local M = {}
local debug_mode = false
local debug_bufffer = vim.api.nvim_create_buf(true, true)
local window = nil
local log = {}
local code_window = nil
local term = nil
local command_out = {
	["gv"] = {},
	["mv"] = {},
	["lv"] = {},
	["bt"] = {},
}

local translations = {
	["gv"] = "global",
	["mv"] = "member",
	["lv"] = "local",
	["bt"] = "stack",
	hr = "-----------------------",
}
local command_queue = {}
local running_command = nil
--------------------------------------------------------
-- defaults
local config = {
	bin = "godot",
	watcher_window = {
		relative = "win",
		row = 0,
		col = 300,
		width = 50,
		height = 99,
	},
}

--------------------------------------------------------
-- setup
M.setup = function(opts)
	config = vim.tbl_deep_extend("force", config, opts)
end

-- Debug
vim.keymap.set("n", "<leader>dq", function()
	M.queue_debug_command("q")
	M.update()
end, { silent = true })
vim.keymap.set("n", "<leader>ds", function()
	M.step()
	M.update()
end, { silent = true })
--------------------------------------------------------
-- private
M.step = function()
	M.queue_debug_command("s")
	M.print_variables()
end

M.print_variables = function()
	M.queue_debug_command("gv")
	M.queue_debug_command("mv")
	M.queue_debug_command("lv")
	M.queue_debug_command("bt")
end

M.update = function()
	if not debug_mode or running_command or vim.tbl_isempty(command_queue) then
		return
	end
	running_command = command_queue[1]
	table.remove(command_queue, 1)
	term:send(running_command)
end

M.queue_debug_command = function(command)
	if not debug_mode or vim.tbl_contains(command_queue, command) then
		return
	end
	command_out[command] = {}
	table.insert(command_queue, command)
end

M.update_watcher = function()
	if not window then
		window = vim.api.nvim_open_win(debug_bufffer, false, config.watcher_window)
	end

	local print = {
		translations.hr,
		"Godot Debugger 0.1v",
		translations.hr,
        " "
	}
	table.insert(print, translations.gv)
    table.insert(print, translations.hr)
	for _, line in pairs(command_out["gv"]) do
		table.insert(print, '+'..line)
	end

	table.insert(print, " ")
	table.insert(print, translations.mv)
    table.insert(print, translations.hr)
	for _, line in pairs(command_out["mv"]) do
		table.insert(print, '+' .. line)
	end
	table.insert(print, " ")
	table.insert(print, translations.lv)
    table.insert(print, translations.hr)
	for _, line in pairs(command_out["lv"]) do
		table.insert(print, '+' .. line)
	end
	table.insert(print, " ")
	table.insert(print, translations.bt)
    table.insert(print, translations.hr)
	for _, line in pairs(command_out["bt"]) do
		table.insert(print, line)
	end

	vim.api.nvim_buf_set_lines(debug_bufffer, 0, -1, true, print)
end

M.on_stdout = function(t, n, d)
	for _, line in pairs(d) do
		if running_command ~= nil and debug_mode then
			if string.find(line, "debug>") and not string.find(line, running_command) then
				running_command = nil
				M.update_watcher()
				a.nvim_set_current_win(code_window)
			elseif not string.find(line, running_command) and string.len(line) > 2 then
				table.insert(command_out[running_command], line)
			end
		end

		if not debug_mode and string.find(line, "debug>") then
			debug_mode = true
			a.nvim_set_current_win(code_window)
			M.print_variables()
		end
	end
	M.update()
end

M.close = function()
	debugging = false
	vim.api.nvim_win_close(window, true)
end

M.create_debug_terminal = function(args)
	return Terminal:new({
		cmd = args,
		direction = "horizontal",
		opts = {
			width = 99999,
			height = 10,
		},
		count = 2,
		on_stdout = M.on_stdout,
		on_exit = M.close,
	})
end
--------------------------------------------------------
-- public
M.debug = function()
	local debug = M.create_debug_terminal("-d ")
	debug:open()
end

M.debug_at_cursor = function()
	local breapoint = "res://" .. vim.fn.expand("%") .. ":" .. vim.api.nvim_win_get_cursor(0)[1]
	local debug_cmd = config.bin
		.. " --path /home/lommix/Projects/Panzer-chan -d -b res://addons/lommix_infinite_worlds/nodes/auto_tilemap.gd:67"
	local debug = M.create_debug_terminal(debug_cmd)

	code_window = a.nvim_get_current_win()
	debug:open()
	term = debug
end

return M
