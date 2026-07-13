-- which-key — discoverability for the bujo keymaps. The individual mappings
-- carry their own `desc` (set in bujo/init.lua and config/vim.lua), so this
-- only needs the group labels.
return {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {
        spec = {
            { '<leader>b', group = 'Buffers' },
            { '<leader>f', group = 'File/Find' },
            { '<leader>n', group = 'Notes' },
            { '<leader>p', group = 'Project' },
            { '<leader>q', group = 'Quit' },
            { '<leader>w', group = 'Windows' },
        },
    },
    keys = {
        {
            '<leader>?',
            function()
                require('which-key').show { global = false }
            end,
            desc = 'Buffer local keymaps (which-key)',
        },
    },
}
