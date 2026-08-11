return {
    'nvim-treesitter/nvim-treesitter',
    -- The frozen `master` branch crashes on Neovim 0.12: its query
    -- directives predate the 0.12 directive API (match is now a node
    -- list). The `main` rewrite is the supported branch; it has no
    -- `.configs` API, so highlighting is started per-filetype below.
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    config = function()
        require('nvim-treesitter').install { 'sql' }
        vim.api.nvim_create_autocmd('FileType', {
            pattern = 'sql',
            callback = function()
                vim.treesitter.start()
            end,
        })
    end,
}
