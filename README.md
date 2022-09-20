# godot.nvim
Break free of godots built-in editor prison and fly my friend!

[godotnvim.webm](https://user-images.githubusercontent.com/84206502/191308246-8d6d963f-1934-4339-ae87-dbec4d62e2f4.webm)


# Features
Mvp debugging tool for nvim. Start your application in debug mode. Quick debug with break-at-cursor support. Step, read and continue any time.

If you love godot, but require vim to stay sane, this if my offering to you.

# Plans
Features comming soon:
- new command! run-to-cursor in debug mode
- pre-build configs for treesitter, lsp and external-editor support scripts.

This is my first nvim plugin, any help offered is appreciated.
I plan on working with godot and nvim for a long time to come.

# Installation
Currenlty relies on https://github.com/akinsho/toggleterm.nvim
```
use('lommix/godot.nvim')
```

# Config
This plugin offers the following mappable commands:
```
:GodotDebug :GodotBreakAtCursor :GodotStep :GodotQuit :GodotContinue
```

Here is my example configuration. Make sure to pass the correct path to the godot executable. I linked mine in the shared globals.
```
--godot.lua
local ok, godot = pcall(require, "godot")
if not ok then
	return
end


-- default config
local config = {
-- 	bin = "godot",
-- 	gui = {
-- 		console_config = @config for vim.api.nvim_open_win
-- 	},
}

godot.setup(config)

local function map(m, k, v)
	vim.keymap.set(m, k, v, { silent = true })
end

map("n", "<leader>dr", godot.debugger.debug)
map("n", "<leader>dd", godot.debugger.debug_at_cursor)
map("n", "<leader>dq", godot.debugger.quit)
map("n", "<leader>dc", godot.debugger.continue)
map("n", "<leader>ds", godot.debugger.step)

```
