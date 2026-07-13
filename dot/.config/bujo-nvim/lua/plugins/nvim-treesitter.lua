return {
    'nvim-treesitter/nvim-treesitter',
    -- Pin the stable classic branch (same reasoning as pg-nvim): the `main`
    -- rewrite dropped the `.configs` setup API (ensure_installed/highlight).
    branch = 'master',
    lazy = false,
    build = ':TSUpdate',
    config = function()
        require('nvim-treesitter.configs').setup {
            ensure_installed = { 'markdown', 'markdown_inline' },
            highlight = { enable = true },
        }
    end,
}
