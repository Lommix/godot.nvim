local Terminal = require("toggleterm.terminal").Terminal

M = {
	prompt = nil,
	log = {},
	command_current = nil,
	command_queue = {},
	command_output = {},
	current_state = function() end,
	on_queue_clear = function() end,
	on_debug_enter = function() end,
	on_debug_exit = function() end,
	on_stdout = function() end,
	on_log_update = function() end,
	request = function() end,
	setup = function() end,
}

local config = {
	hidden = true,
	on_stdout = M.on_stdout,
}

local state = {
	running = 1,
	ready = 2,
	process = 3,
}

state.impl = {
	[state.running] = {
		run = function(data)
			for _, line in pairs(data) do
				if string.len(line) > 1 then
					table.insert(M.log, line)
					M.on_log_update(line)
				end
			end
		end,
		switch = function(data)
			for _, line in pairs(data) do
				if string.find(line, "debug>") then
					M.current_state = state.ready
					if M.on_debug_enter then
						M.on_debug_enter()
					end
				end
			end
		end,
	},
	[state.ready] = {
		run = function()
			if vim.tbl_isempty(M.command_queue) then
				return
			end
			-- pop command queue
			M.command_current = M.command_queue[1]
			table.remove(M.command_queue, 1)

            -- ready state has to be left in the same frame, there will be no calls until next command

			M.prompt:send(M.command_current)
			M.current_state = state.process
			-- quit
			if M.command_current == "q" and M.on_debug_exit then
				M.on_debug_exit()
				M.command_current = nil
				M.current_state = state.running
			end

			if M.command_current == "c" then
				M.current_state = state.running
				M.command_current = nil
			end
		end,
	},
	[state.process] = {
		run = function(data)
			for _, line in pairs(data) do
				if string.find(line, M.command_current) then
					goto continue
				end

				if string.find(line, "debug>") and not string.find(line, M.command_current) then
					M.command_current = nil
				elseif string.len(line) > 1 then
					table.insert(M.command_output[M.command_current], line)
					if M.command_current == "s" then
						table.insert(M.log, line)
						M.on_log_update(line)
					end
				end
				::continue::
			end
		end,
		switch = function(data)
			for _, line in pairs(data) do
				if string.find(line, "debug>") then
					M.current_state = state.ready
					if not vim.tbl_isempty(M.command_queue) then
						state.impl[M.current_state].run()
					else
						M.on_queue_clear()
					end
				end
			end
		end,
	},
}
------------------------------------------------------------------------
-- setup
-- @param opts table?
M.setup = function(opts)
	opts = opts or {}
	config = vim.tbl_deep_extend("force", config, opts)
end
-------------------------------------------------------------------
-- spawn
-- @param start_command string?
M.spawn = function(start_command)
	M.prompt = Terminal:new({
		cmd = start_command,
		hidden = true,
		on_stdout = M.on_stdout,
	})
	M.current_state = state.running
	M.prompt:spawn()
end
-------------------------------------------------------------------
-- requesting command response
-- @param commands string|string[]
M.request = function(commands, callback)
	if M.current_state ~= state.ready then
		do
			return
		end
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
-------------------------------------------------------------------
-- toggleterm stdout adapter
M.on_stdout = function(_, _, data)
	if M.current_state then
		state.impl[M.current_state].run(data)
		state.impl[M.current_state].switch(data)
	end
end

return M
