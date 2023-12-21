-- Theme configuration
require('tokyonight').setup {
    style = 'day',
    styles = {
        functions = {
            italic = true,
        },
    },
    on_colors = function(colors)
        colors.fg_gutter = '#555f8b'
    end,
    on_highlights = function(hl, c)
        hl.CursorLineNr = {
            fg = c.cyan,
        }
        hl.Visual = {
            bg = '#2f334d',
        }
        hl.ColorColumn = {
            bg = '#222436',
        }
    end,
}

vim.cmd [[colorscheme tokyonight]]
