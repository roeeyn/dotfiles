return {
    'otavioschwanck/arrow.nvim',
    opts = {
        show_icons = true,
        separate_by_branch = true, -- Bookmarks will be separated by git branch
        leader_key = ' M', -- Recommended to be a single key
        buffer_leader_key = ' m', -- Per Buffer Mappings
        mappings = {
            edit = 'e',
            delete_mode = 'd',
            clear_all_items = 'X',
            toggle = 's', -- used as save if separate_save_and_remove is true
            open_vertical = 'v',
            open_horizontal = '-',
            quit = 'q',
            remove = 'x', -- only used if separate_save_and_remove is true
            next_item = '[',
            prev_item = ']',
        },
    },
}
