----------------------------------------------------------------------
--         Personal customization for keymaps, vim options,         --
--                     vim autocmds and plugins                     --
----------------------------------------------------------------------
require 'roeeyn.vim_auto_commands'
require 'roeeyn.key_mappings'
require 'roeeyn.vim_options'
require 'roeeyn.plugins'
require 'roeeyn.snippets'

P = function(v)
  print(vim.inspect(v))
  return v
end

RELOAD = function(...)
  return require('plenary.reload').reload_module(...)
end

R = function(name)
  RELOAD(name)
  return require(name)
end
