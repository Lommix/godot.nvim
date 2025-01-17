local ok, ts = pcall(require, "nvim-treesitter.configs")
if not ok then
	return
end

-- every "setup" run his own config
-- @see https://github.com/nvim-treesitter/nvim-treesitter/blob/4d7580099155065f196a12d7fab412e9eb1526df/lua/nvim-treesitter/configs.lua#L371-L372
ts.setup({
	ensure_installed = { "gdscript", "godot_resource", "gdshader" },
})
