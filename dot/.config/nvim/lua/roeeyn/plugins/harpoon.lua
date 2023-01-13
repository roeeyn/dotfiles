local telescope = require 'telescope'
local actions = require 'telescope.actions'

local M = {}

function M.open_harpoon_telescope()
  return telescope.extensions.harpoon.marks {
    attach_mappings = function(_, map)
      map('i', '<c-d>', actions.preview_scrolling_down)
      return true
    end,
  }
end

return M
