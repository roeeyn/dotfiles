return {
    -- Distinct green palette so pg-nvim is instantly distinguishable from
    -- gruvbox (slim-nvim) and tokyonight (main nvim).
    'neanias/everforest-nvim',
    lazy = false,
    priority = 1000,
    opts = {
        background = 'soft',
        transparent_background_level = 2, -- match slim-nvim's transparent look
        italics = false,
        disable_italic_comments = true,
    },
    config = function(_, opts)
        require('everforest').setup(opts)
        vim.cmd.colorscheme 'everforest'
    end,
}
