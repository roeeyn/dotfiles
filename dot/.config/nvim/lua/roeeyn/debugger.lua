require'dap-python'.setup('/Users/rodrigom/src/roadsideassistance/venv/bin/python')

require("nvim-dap-virtual-text").setup{
  -- If we want to use comments to identify the virtual text
  commented = false
}

require("dapui").setup()
