-- LSP Configuration
local function on_attach()
	-- TODO: TJ told me to do this and I should do it because he is Telescopic
	-- "Big Tech" "Cash Money" Johnson
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.foldingRange = {
	dynamicRegistration = false,
	lineFoldingOnly = true,
}

require("lspconfig").ansiblels.setup({
	on_attach = on_attach,
	capabilities = capabilities,
})
require("lspconfig").dockerls.setup({
	on_attach = on_attach,
	capabilities = capabilities,
})
require("lspconfig").elixirls.setup({
	-- Unix (Install from here -> https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#elixirls)
	on_attach = on_attach,
	capabilities = capabilities,
	cmd = { "/Users/roeeyn/.local/bin/elixir-ls/language_server.sh" },
})
require("lspconfig").bashls.setup({
	on_attach = on_attach,
	capabilities = capabilities,
})
require("lspconfig").gopls.setup({
	on_attach = on_attach,
	capabilities = capabilities,
})
require("lspconfig").tsserver.setup({
	on_attach = on_attach,
	capabilities = capabilities,
})
require("lspconfig").pyright.setup({
	on_attach = on_attach,
	capabilities = capabilities,
	settings = { python = { venv_path = "~/.pyenv/versions" } },
})
require("lspconfig").rust_analyzer.setup({
	on_attach = on_attach,
	capabilities = capabilities,
})
require("lspconfig").html.setup({
	on_attach = on_attach,
	capabilities = capabilities,
})
require("lspconfig").svelte.setup({
	on_attach = on_attach,
	capabilities = capabilities,
})
require("lspconfig").jsonls.setup({
	on_attach = on_attach,
	capabilities = capabilities,
	commands = {
		Format = {
			function()
				vim.lsp.buf.range_formatting({}, { 0, 0 }, { vim.fn.line("$"), 0 })
			end,
		},
	},
})
require("lspconfig").sumneko_lua.setup({
	on_attach = on_attach,
	capabilities = capabilities,
	settings = {
		Lua = {
			runtime = {
				-- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
				version = "LuaJIT",
			},
			diagnostics = {
				-- Get the language server to recognize the `vim` global
				globals = { "vim", "hs", "spoon" },
			},
			workspace = {
				-- Make the server aware of Neovim runtime files
				library = vim.api.nvim_get_runtime_file("", true),
			},
			-- Do not send telemetry data containing a randomized but unique identifier
			telemetry = {
				enable = false,
			},
		},
	},
})
