local parsers = {
    'bash',
    'css',
    'dockerfile',
    'elixir',
    'heex',
    'html',
    'javascript',
    'json',
    'lua',
    'markdown',
    'markdown_inline',
    'python',
    'sql',
    'typescript',
    'vim',
    'vimdoc',
    'yaml',
}

return {
    'nvim-treesitter/nvim-treesitter',
    -- The frozen `master` branch crashes on Neovim 0.12: its injection
    -- directives predate the 0.12 directive API (match is now a node list).
    -- The `main` rewrite is the supported branch.
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    config = function()
        require('nvim-treesitter').install(parsers)

        -- Matching on '*' rather than the parser list: FileType fires with
        -- filetype names, which are not parser names (`sh` uses the `bash`
        -- parser, `help` uses `vimdoc`). vim.treesitter.start() resolves the
        -- mapping itself and errors when no parser exists, so pcall doubles
        -- as the "is this filetype supported" test.
        vim.api.nvim_create_autocmd('FileType', {
            pattern = '*',
            callback = function()
                if not pcall(vim.treesitter.start) then
                    return
                end
                vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end,
        })
    end,
}
