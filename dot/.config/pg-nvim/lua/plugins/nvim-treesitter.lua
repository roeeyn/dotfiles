return {
    'nvim-treesitter/nvim-treesitter',
    -- Pin the stable classic branch: its `main` rewrite dropped the
    -- `.configs` setup API (ensure_installed/highlight). `sql` is not a
    -- Neovim-bundled parser, so we need that API to install + highlight it.
    branch = 'master',
    lazy = false,
    build = ':TSUpdate',
    config = function()
        require('nvim-treesitter.configs').setup {
            ensure_installed = { 'sql' },
            highlight = { enable = true },
        }
    end,
}
