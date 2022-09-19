local M = {}
local godot = require("godot.debugger")
local config = {
	mappings = {
		debug = "<leader>dr",
	},
}

godot.setup(config)

local function map(m, k, v)
	vim.keymap.set(m, k, v, { silent = true })
end

map("n", "<leader>dr", godot.debug)
map("n", "<leader>dd", function()
	package.loaded["godot.debugger"] = nil
	godot = require("godot.debugger")
	godot.setup(config)
	godot.debug_at_cursor()
end)
map("n", "<leader>dq", godot.quit)
map("n", "<leader>dc", godot.continue)
map("n", "<leader>ds", godot.step)

M.setup = function(opts)
	config = vim.tbl_deep_extend("force", config, (opts or {}))
end

-- reload on run for debug stuff
return M
