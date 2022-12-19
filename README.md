# godot.nvim

![nvimgodotlogo](https://user-images.githubusercontent.com/84206502/192011201-988b79c3-e688-4c6d-b00b-720aadff35dc.png)

Break free from Godots built-in editor prison and fly! 

[godotnvim.webm](https://user-images.githubusercontent.com/84206502/191308246-8d6d963f-1934-4339-ae87-dbec4d62e2f4.webm)

# Update! 
With godot 4 comes dap integration, which is much better than my solution https://github.com/mfussenegger/nvim-dap

# Features
Minimalist Godot debugging tool for nvim. Run your application in debug, break on error or cursor. 
Works with godot 3 and 4.

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

# How to use nvim as external editor
its pretty simple with nvim remote

create a bash script, make it executeable. add the following context:
```
#!/bin/bash
[ -n "$1" ] && file=$1
nvim --server ~/.cache/nvim/godot.pipe --remote-send ':e '$file'<CR>'
```

Now start nvim in your project folder and listen to the pipe file:
```
nvim --listen ~/.cache/nvim/godot.pipe .
```

Add external config to your editor settings with the path to the script:
![Screenshot from 2022-10-14 13-17-14](https://user-images.githubusercontent.com/84206502/195834456-41d65a9e-172b-4a45-a352-f976e2a19be8.png)

Done! if you click on the script icon in godot, nvim will open the file. Have fun!
