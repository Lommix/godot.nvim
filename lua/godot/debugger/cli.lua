local Terminal = require("toggleterm.terminal").Terminal

M = {
	prompt = nil,
	log = {},
	command_current = nil,
	command_queue = {},
	command_output = {},
	current_state = nil,
	on_queue_clear = nil,
	on_debug_enter = nil,
    on_debug_exit = nil,
	on_stdout = nil,
	request = nil,
	setup = nil,
}

local state = {
	running = 1,
	waiting = 2,
	process = 3,
}

state.impl = {
	[state.running] = {
		run = function(data)
			for _, line in pairs(data) do
				if string.len(line) > 1 then
					table.insert(M.log, line)
				end
			end
		end,
		switch = function(data)
			for _, line in pairs(data) do
				if string.find(line, "debug>") then
					M.current_state = state.waiting
                    if M.on_debug_enter then
                        M.on_debug_enter()
                    end
				end
			end
		end,
	},
	[state.waiting] = {
		run = function()
			if vim.tbl_isempty(M.command_queue) then
				return
			end
			-- pop command queue
			M.command_current = M.command_queue[1]
			table.remove(M.command_queue, 1)

			M.prompt:send(M.command_current)
			M.current_state = state.process
			-- quit
			if M.command_current == "q" and M.on_debug_exit then
				M.on_debug_exit()
			end
		end,
		switch = function()
		end,
	},
	[state.process] = {
		run = function(data)
			for _, line in pairs(data) do
				if string.find(line, "debug>") and not string.find(line, M.command_current) then
					M.command_current = nil
				elseif string.len(line) > 1 then
					table.insert(M.command_output[M.command_current], line)
					if M.command_current == "s" then
						table.insert(M.log, line)
					end
				end
			end
		end,
		switch = function()
			for _, line in pairs(data) do
				if string.find(line, "debug>") then
					M.current_state = state.waiting
					if not vim.tbl_isempty(M.command_queue) then
						state.waiting.run()
						state.waiting.switch()
					else
						M.on_queue_clear()
					end
				end
			end
		end,
	},
}
------------------------------------------------------------------------

M.setup = function()
	opts = {
		hidden = true,
		on_stdout = M.on_stdout,
	}
	M.prompt = Terminal:new(opts)
	M.prompt:spawn()
	M.current_state = state.running
end

M.request = function(commands, callback)
	if M.current_state ~= state.waiting then
		return
	end

	if type(commands) == "string" then
		commands = { commands }
	end
	M.on_queue_clear = callback

	for _, command in ipairs(commands) do
		table.insert(M.command_queue, command)
		M.command_output[command] = {}
	end

	state.impl[M.current_state].run()
end

M.on_stdout = function(_, _, data)
	if M.current_state then
		state.impl[M.current_state].run(data)
		state.impl[M.current_state].switch(data)
	end
end

return M
