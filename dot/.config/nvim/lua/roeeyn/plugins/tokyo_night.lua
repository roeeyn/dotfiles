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
}

vim.cmd [[colorscheme tokyonight]]
vim.cmd [[hi CursorLineNr guifg=#5dccf5]]
