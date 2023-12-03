local telescope = require 'telescope'
local actions = require 'telescope.actions'

local harpoon = require 'harpoon'
harpoon:setup()

local M = {}

function M.add_file()
    harpoon:list():append()
    print 'Mark added to harpoon'
end

function M.select_file(index)
    harpoon:list():select(index)
end

function M.prev()
    harpoon:list():prev()
end

function M.next()
    harpoon:list():next()
end

function M.quick_ui()
    harpoon.ui:toggle_quick_menu(harpoon:list())
end

function M.clear_all()
    harpoon:list():clear()
    print 'Removed harpoons'
end

function M.telescope()
    return telescope.extensions.harpoon.marks {
        attach_mappings = function(_, map)
            map('i', '<c-d>', actions.preview_scrolling_down)
            return true
        end,
    }
end

return M
