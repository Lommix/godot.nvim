local Terminal = require("toggleterm.terminal").Terminal

M = {}

-----------------------------------------------------------
-- private
local _prompt = nil
local _queue = {}
local _request = nil
local _response = {}
local _callback = nil
local _console_log_callback = nil
-----------------------------------------------------------
-- default config
local config = {
	hidden = true,
	on_stdout = M.on_stdout,
	godot_api = {
		locals = "lv",
		members = "mv",
		globals = "gv",
		print = "p",
		trace = "bt",
		continue = "c",
		quit = "q",
		step = "s",
		keywords = {
			prompt = "debug>",
		},
	},
}
-----------------------------------------------------------
-- chain next command from queue
local process_queue = function()
	_request = nil
	_response = {}
	if vim.tbl_count(_queue) > 0 then
		local next = _queue[1]
		table.remove(_queue, 1)
		_callback = next.callback
		_request = next.question
		_prompt:send(_request)
	end
end
-----------------------------------------------------------
-- on stdout handler
local on_response = function(_, _, data)
	for _, line in ipairs(data) do
		line = string.gsub(line, "%c", "")
		if string.len(line) > 0 then
			-- current command
			if _request and not string.find(line, _request) then
				if string.find(line, config.godot_api.keywords.prompt) then
					local _r = _response
					local _c = _callback

					process_queue()

					if _c then
						_c(_r)
					end
				else
					table.insert(_response, line)
				end
			end
			if
				_console_log_callback
				and (not _request or _request == "log")
				and string.len(line) > 0
				and not string.find(line, config.godot_api.keywords.prompt)
			then
				_console_log_callback(line)
			end
		end
	end
end
------------------------------------------------------------------------
-- requesting commands in debug mode
local request = function(question, callback)
	if not _request then
		_callback = callback
		_request = question
		_prompt:send(question)
	else
		table.insert(_queue, {
			question = question,
			callback = callback,
		})
	end
end
------------------------------------------------------------------------
-- public requests
M.request_globals = function(callback)
	request(config.godot_api.globals, callback)
end
M.request_members = function(callback)
	request(config.godot_api.members, callback)
end
M.request_trace = function(callback)
	request(config.godot_api.trace, callback)
end
M.request_locals = function(callback)
	request(config.godot_api.locals, callback)
end
M.request_step = function(callback)
	request(config.godot_api.step, callback)
end
------------------------------------------------------------------------
M.quit = function(callback)
	_prompt:shutdown()
	_queue = {}
	_response = {}
	_callback = nil
	_request = nil
	callback()
end
------------------------------------------------------------------------
M.continue = function(callback)
	_prompt:send(config.godot_api.continue)
	_queue = {}
	_response = {}
	_callback = callback
	_request = "log"
end
------------------------------------------------------------------------
-- public spawn
-- @param start_command string?
M.spawn = function(start_command, on_enter_debug, on_log)
	_console_log_callback = on_log
	_request = "log"
	_callback = on_enter_debug
	_prompt = Terminal:new({
		cmd = start_command,
		hidden = true,
		on_stdout = on_response,
	})
	_prompt:spawn()
end

return M
