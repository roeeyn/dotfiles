return {
    {
        'nvim-lua/plenary.nvim',
        lazy = true,
    },
    {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
            return vim.fn.executable 'make' == 1
        end,
    },
    {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.8',
        dependencies = {
            'nvim-lua/plenary.nvim',
            'nvim-telescope/telescope-fzf-native.nvim',
        },
        config = function()
            local telescope = require 'telescope'

            telescope.setup {
                pickers = {
                    colorscheme = {
                        enable_preview = true,
                    },
                    find_files = {
                        hidden = true,
                    },
                    live_grep = {
                        additional_args = function(opts)
                            return {
                                '--hidden',
                            }
                        end,
                    },
                },
                extensions = {
                    fzf = {
                        fuzzy = true, -- false will only do exact matching
                        override_generic_sorter = true, -- override the generic sorter
                        override_file_sorter = true, -- override the file sorter
                        case_mode = 'smart_case', -- or "ignore_case" or "respect_case"
                    },
                },
            }

            -- Load fzf extension
            pcall(telescope.load_extension, 'fzf')
        end,
    },
}
