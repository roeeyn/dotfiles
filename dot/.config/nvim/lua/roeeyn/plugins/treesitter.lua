-- Treesitter configuration
require('nvim-treesitter.configs').setup {
  -- Add languages to be installed here that you want installed for treesitter
  ensure_installed = {
    'go',
    'javascript',
    'json',
    'json5',
    'jsonc',
    'lua',
    'markdown',
    'markdown_inline',
    'python',
    'rust',
    'typescript',
    'vim',
  },

  highlight = { enable = true },
  -- indent = {enable = true}
  autotag = {
    enable = true,
  },
  textsubjects = {
    enable = true,
    prev_selection = ',', -- (Optional) keymap to select the previous selection
    keymaps = {
      ['.'] = 'textsubjects-smart',
      [';'] = 'textsubjects-container-outer',
      ['i;'] = 'textsubjects-container-inner',
    },
  },
  playground = {
    enable = true,
  },
}
