return {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    -- Loaded on demand: lazy.nvim resolves require('telescope...') from the
    -- bujo picker functions, so nothing telescope-related runs at startup.
    lazy = true,
    cmd = 'Telescope',
    opts = {},
}
