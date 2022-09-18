local ok, lsp_config = pcall(require, "lspconfig")
if not ok then
	return
end

-- run default lsp config for gdscript
-- godot is the language server, projects needs to be opened to work
lsp_config.gdscript.setup({})
