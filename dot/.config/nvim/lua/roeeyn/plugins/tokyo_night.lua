-- Theme configuration
require('tokyonight').setup {
  style = 'night',
  styles = {
    functions = {
      italic = true,
    },
  },
  on_colors = function(colors)
    -- colors.dark5 = "#93d8d9"
    colors.fg_gutter = '#555f8b'
  end,
  on_highlights = function(hl, c)
    hl.CursorLineNr = {
      fg = c.cyan,
    }
    hl.Visual = {
      bg = '#2f334d',
    }
  end,
}

vim.cmd [[colorscheme tokyonight]]
