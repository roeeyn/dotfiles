-- kanagawa (lotus, the light variant) — deliberately different from the
-- code editors so the notes app is instantly recognizable. Note: `wave` is
-- kanagawa's DARK variant despite the painting association; `lotus` is the
-- light palette.
return {
    'rebelot/kanagawa.nvim',
    lazy = false,
    priority = 1000,
    opts = {
        theme = 'lotus',
    },
    config = function(_, opts)
        require('kanagawa').setup(opts)
        vim.o.background = 'light'
        vim.cmd.colorscheme 'kanagawa-lotus'
    end,
}
