----------------------------------------------------------------------
--         Personal customization for keymaps, vim options,         --
--                     vim autocmds and plugins                     --
----------------------------------------------------------------------
require('roeeyn.vim_auto_commands')
require('roeeyn.key_mappings')
require('roeeyn.vim_options')
require('roeeyn.plugins')

local M = {}

function M.reload_config()
  for name,_ in pairs(package.loaded) do
    if name:match('^roeeyn') and not name:match('nvim-tree') then
      package.loaded[name] = nil
    end
  end

  dofile(vim.env.MYVIMRC)
  vim.notify("Nvim configuration reloaded!", vim.log.levels.INFO)
end

return M
