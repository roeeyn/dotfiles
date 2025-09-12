return {
    'nvim-lualine/lualine.nvim',
    dependencies = {
        'nvim-tree/nvim-web-devicons',
    },
    opts = {
        options = {
            theme = 'tokyonight',
        },
        extensions = { 'quickfix', 'nvim-tree', 'trouble' },
        sections = {
            lualine_b = {
                'branch',
                'diff',
                "require('arrow.statusline').text_for_statusline_with_icons()",
                'diagnostics',
            },
        },
    },
}
