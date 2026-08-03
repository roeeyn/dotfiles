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

        -- Priority marker (bujo/priority.lua): its default link is
        -- DiagnosticWarn, which lotus maps to lotusOrange2 (#e98a00) — too
        -- washed out on the pale background. Use the darker lotusOrange,
        -- bold. Defined here (post-colorscheme, no `default`) so it wins
        -- over the module's `default = true` link.
        vim.api.nvim_set_hl(0, 'BujoPriority', { fg = '#cc6d00', bold = true })
    end,
}
