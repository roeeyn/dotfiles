local conf = require('telescope.config').values

local harpoon = require 'harpoon'
harpoon:setup()

local M = {}

function M.add_file()
    harpoon:list():add()
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
    local harpoon_files = harpoon:list()
    local file_paths = {}
    for _, item in ipairs(harpoon_files.items) do
        table.insert(file_paths, item.value)
    end

    require('telescope.pickers')
        .new({}, {
            prompt_title = 'Harpoon',
            finder = require('telescope.finders').new_table {
                results = file_paths,
            },
            previewer = conf.file_previewer {},
            sorter = conf.generic_sorter {},
        })
        :find()
end

return M
