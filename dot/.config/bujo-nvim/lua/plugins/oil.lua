return {
    'stevearc/oil.nvim',
    keys = {
        { '-', '<cmd>Oil<cr>', desc = 'File browser (parent dir)' },
        { '<leader>po', '<cmd>Oil<cr>', desc = 'Oil file browser (mirrors main nvim)' },
    },
    cmd = 'Oil',
    opts = {
        view_options = {
            show_hidden = true,
        },
    },
}
