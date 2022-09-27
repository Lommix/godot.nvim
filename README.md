# godot.nvim

![nvimgodotlogo](https://user-images.githubusercontent.com/84206502/192011201-988b79c3-e688-4c6d-b00b-720aadff35dc.png)

Break free from Godots built-in editor prison and fly! 

[godotnvim.webm](https://user-images.githubusercontent.com/84206502/191308246-8d6d963f-1934-4339-ae87-dbec4d62e2f4.webm)


# Features
Godot debugging tool for nvim. Run your application in debug, break on error or cursor. Step, read and continue.

If you love godot, but require vim to stay sane, this is my offering to you.

Works with godot 3 and 4.

# Plans
- pre-build configs for treesitter, lsp and external-editor shell scripts
- luasnips for gdscript.
- c# support


# Installation
Any plugin manager will do.
```
use('lommix/godot.nvim')
```

# Config
Plugin adds the following commands:
```
:GodotDebug :GodotBreakAtCursor :GodotStep :GodotQuit :GodotContinue
```

Here is my example configuration. Make sure to pass the correct path to the godot executable.

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
