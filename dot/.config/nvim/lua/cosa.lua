require('packer').startup(function(use)
    -- useful hover information over different code parts
    use {
        'lewis6991/hover.nvim',
        config = function()
            require('hover').setup {
                init = function()
                    -- Require providers
                    require 'hover.providers.lsp'
                    require 'hover.providers.gh' -- requires the gh command
                    require 'hover.providers.gh_user' -- requires the gh command
                    -- require('hover.providers.jira') -- requires the jira command
                    require 'hover.providers.man'
                    require 'hover.providers.dictionary'
                end,
                preview_opts = {
                    border = 'single',
                },
                -- Whether the contents of a currently open hover window should be moved
                -- to a :h preview-window when pressing the hover keymap.
                preview_window = true,
                title = true,
                mouse_providers = {
                    'LSP',
                },
                mouse_delay = 1000,
            }

            -- Setup keymaps
            -- vim.keymap.set("n", "K", require("hover").hover, {desc = "hover.nvim"})
            -- vim.keymap.set("n", "gK", require("hover").hover_select, {desc = "hover.nvim (select)"})
            vim.keymap.set('n', '<C-p>', function()
                require('hover').hover_switch 'previous'
            end, { desc = 'hover.nvim (previous source)' })
            vim.keymap.set('n', '<C-n>', function()
                require('hover').hover_switch 'next'
            end, { desc = 'hover.nvim (next source)' })

            -- Mouse support
            -- vim.keymap.set('n', '<MouseMove>', require('hover').hover_mouse, { desc = "hover.nvim (mouse)" })
            -- vim.o.mousemoveevent = true
        end,
    }

    -- Nice dashboard
    use {
        'goolord/alpha-nvim',
        config = function()
            require('roeeyn.plugins.alpha').setup()
        end,
    }

    -- Awesome testing
    use {
        'vim-test/vim-test',
        config = function()
            vim.g['test#strategy'] = 'neovim'
            vim.g['test#neovim#term_position'] = 'vert botright'
            vim.g['test#neovim#start_normal'] = 1 -- Start in normal mode so we can scroll
        end,
    }

    -- Annotation Toolkit (documentation)
    use {
        'danymat/neogen',
        config = function()
            require('neogen').setup {
                snippet_engine = 'luasnip',
            }
        end,
        requires = 'nvim-treesitter/nvim-treesitter',
        -- Uncomment next line if you want to follow only stable versions
        -- tag = "*"
    }

    use {
        'folke/trouble.nvim',
        requires = {
            'nvim-web-devicons',
        },
        config = function()
            require('trouble').setup {
                icons = true,
                auto_open = false,
                auto_close = false,
                auto_preview = true,
                auto_fold = false,
                use_diagnostic_signs = false,
            }
        end,
    }

    -- GitHub Copilot
    use {
        'zbirenbaum/copilot.lua',
        cmd = 'Copilot',
        event = 'InsertEnter',
        config = function()
            require('copilot').setup {
                suggestion = { enabled = false },
                panel = { enabled = false },
            }
        end,
    }
    use {
        'zbirenbaum/copilot-cmp',
        after = { 'copilot.lua' },
        config = function()
            require('copilot_cmp').setup {
                formatters = {
                    insert_text = require('copilot_cmp.format').remove_existing,
                },
            }
        end,
    }

    -- Completion
    use {
        'hrsh7th/nvim-cmp',
        requires = {
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-cmdline',
            'hrsh7th/cmp-nvim-lsp-signature-help',
            'hrsh7th/cmp-git',
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-nvim-lua',
            'hrsh7th/cmp-path',
            'hrsh7th/cmp-calc',
            'hrsh7th/cmp-emoji',
            'ray-x/cmp-treesitter',
            -- Snippets
            'L3MON4D3/LuaSnip',
            'saadparwaiz1/cmp_luasnip',
            'rafamadriz/friendly-snippets',
        },
    }

    -- Nice icons for cmp window
    use 'onsails/lspkind.nvim'

    -- LSP configuration
    -- TODO: Improve LSP configuration
    use { -- LSP Configuration & Plugins
        'neovim/nvim-lspconfig',
        requires = {
            -- Automatically install LSPs to stdpath for neovim
            'williamboman/mason.nvim',
            'williamboman/mason-lspconfig.nvim',

            -- For formatting and linting
            'jose-elias-alvarez/null-ls.nvim',

            -- Additional lua configuration, makes nvim stuff amazing
            'folke/neodev.nvim',
        },
    }

    -- TODO: Add format configuration
    use {
        'stevearc/conform.nvim',
        config = function()
            require('conform').setup()
        end,
    }
end)
