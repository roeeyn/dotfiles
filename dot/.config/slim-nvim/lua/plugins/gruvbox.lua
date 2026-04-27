return {
    'ellisonleao/gruvbox.nvim',
    lazy = false,
    priority = 1000,
    opts = {
        contrast = 'soft',
        transparent_mode = true,
        italic = {
            strings = false,
            emphasis = false,
            comments = false,
            operators = false,
            folds = false,
        },
    },
    config = function(_, opts)
        require('gruvbox').setup(opts)
        vim.cmd.colorscheme 'gruvbox'
    end,
}
