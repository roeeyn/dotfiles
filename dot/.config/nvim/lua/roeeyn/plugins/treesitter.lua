-- Treesitter configuration
require('nvim-treesitter.configs').setup {
  -- Add languages to be installed here that you want installed for treesitter
  ensure_installed = {
    'comment',
    'dockerfile',
    'git_config',
    'git_rebase',
    'gitattributes',
    'gitcommit',
    'gitignore',
    'go',
    'godot_resource',
    'gomod',
    'gosum',
    'gowork',
    'graphql',
    'hjson',
    'html',
    'javascript',
    'json',
    'json5',
    'jsonc',
    'jq',
    'lua',
    'markdown',
    'markdown_inline',
    'make',
    'mermaid',
    'passwd',
    'python',
    'rust',
    'sql',
    'todotxt',
    'typescript',
    'yaml',
    'vim',
    'vimdoc',
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
