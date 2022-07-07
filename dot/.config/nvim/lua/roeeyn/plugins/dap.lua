----------------------------------------------------------------------
--         Configurations for the Debugger Adapter Protocol         --
--                              Plugin                              --
----------------------------------------------------------------------
require'dap-python'.setup('/Users/roeeyn/.pyenv/shims/python')

require("nvim-dap-virtual-text").setup{
  -- If we want to use comments to identify the virtual text
  commented = false
}

require("dapui").setup()
