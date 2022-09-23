local f = vim.fn
local Job = {}

-- stdout handle
local on_stdout = function(job, buffer)
	for _, line in pairs(buffer) do
		-- on enter debug mode
		if string.find(line, "debug>") then
			-- if command return result
			if job.cmd then
				job.response_callback(job.reponse_buffer)
				job.cmd = nil
				job.process_queue()
			end
			job.on_break()
			goto continue
		end

		--skip if empty
		if string.len(vim.trim(line)) == 0 then
			goto continue
		end

		-- command output
		if job.cmd and job.cmd ~= "c" then
			table.insert(job.reponse_buffer, line)
			goto continue
		end

		-- log
		job.on_log(line)

		::continue::
	end
end

-- o = table :
-- @command
-- @cwd
-- @on_log
-- @on_break
-- @on_exit
function Job:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self

	assert(o.cmd, "missing executeable")
	assert(o.on_log, "missing log callback")
	assert(o.on_break, "missing break callback")
	assert(o.cwd, "missing project dir")

	self.on_log = o.on_log
	self.on_exit = o.on_exit
	self.on_break = o.on_break

	self.job_id = f.jobstart(o.cmd, {
		cwd = o.cwd,
		on_stdout = function(_, data)
			on_stdout(self, data)
		end,
		on_exit = self.on_exit,
	})

	self.queue = {}

	function self.process_queue()
		if vim.tbl_count(self.queue) > 0 then
			local next = self.queue[1]
			table.remove(self.queue, 1)
			self.cmd = next[1]
			self.response_callback = next[2]
			self.reponse_buffer = {}
			f.chansend(self.job_id, self.cmd .. "\n")
		end
	end

	function self.request(job, debugger_request, callback)
		if not self.cmd then
			self.cmd = debugger_request
			self.reponse_buffer = {}
			self.response_callback = callback
			f.chansend(self.job_id, debugger_request .. "\n")
		else
			table.insert(self.queue, {
				debugger_request,
				callback,
			})
		end
	end

	function self.shutdown()
		f.jobstop(self.job_id)
	end

	return o
end

return Job
