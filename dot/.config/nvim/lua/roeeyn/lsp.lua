local function on_attach()
    -- TODO: TJ told me to do this and I should do it because he is Telescopic
    -- "Big Tech" "Cash Money" Johnson
end

require'lspconfig'.ansiblels.setup{on_attach=on_attach}
require'lspconfig'.dockerls.setup{on_attach=on_attach}
require'lspconfig'.bashls.setup{on_attach=on_attach}
require('lspconfig').tsserver.setup {on_attach = on_attach}
require('lspconfig').pyright.setup {
    on_attach = on_attach,
    settings = {python = {venv_path = '~/.pyenv/versions'}}
}
require('lspconfig').rust_analyzer.setup {on_attach = on_attach}
require('lspconfig').html.setup {on_attach = on_attach}
require'lspconfig'.svelte.setup {on_attach = on_attach}
require('lspconfig').jsonls.setup {
    on_attach = on_attach,
    commands = {
        Format = {
            function()
                vim.lsp.buf.range_formatting({}, {0, 0}, {vim.fn.line("$"), 0})
            end
        }
    }
}
