----------------------------------------------------------------------
--              List of all the plugins customization               --
----------------------------------------------------------------------

require 'roeeyn.plugins.treesitter'
require 'roeeyn.plugins.luatab'
require 'roeeyn.plugins.indent_blankline'
require 'roeeyn.plugins.lualine'
require 'roeeyn.plugins.fidget'
require 'roeeyn.plugins.gitlinker'
require 'roeeyn.plugins.nvim_comment'
require 'roeeyn.plugins.nvim_lsp'
require 'roeeyn.plugins.nvim_test'
require 'roeeyn.plugins.nvim_tree'
require 'roeeyn.plugins.nvim_ufo'
require 'roeeyn.plugins.telescope'
require 'roeeyn.plugins.tokyo_night'
require 'roeeyn.plugins.flutter_tools'
require 'roeeyn.plugins.nvim_cmp'
require 'roeeyn.plugins.luasnip'
require 'roeeyn.plugins.dap'
require 'roeeyn.plugins.which_key'

require 'impatient'
require('package-info').setup {
  package_manager = 'npm',
}

-- Setup neovim lua configuration
require('neodev').setup()
