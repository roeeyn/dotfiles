return {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000,
    opts = {
        -- style = 'moon',
        on_highlights = function(hl, c)
            local util = require 'tokyonight.util'
            -- Subtle, lightened blue-gray that fits the theme
            local line_color = util.lighten(c.fg_gutter, 0.4)

            hl.LineNr = { fg = line_color }
            hl.LineNrAbove = { fg = line_color }
            hl.LineNrBelow = { fg = line_color }
        end,
    },
    config = function(plugin, opts)
        require('tokyonight').setup(opts)
        vim.cmd [[colorscheme tokyonight]]
    end,
}
