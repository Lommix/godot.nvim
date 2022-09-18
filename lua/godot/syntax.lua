local ok, ts = pcall(require, "nvim-treesitter.configs")
if not ok then
	return
end

ts.setup({
    -- does this overwrite your old ensure_installed config?
	ensure_installed = {"gdscript"}
})
