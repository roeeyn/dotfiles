-- Plugin Manager bootstrapping
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system {
        'git',
        'clone',
        '--filter=blob:none',
        'https://github.com/folke/lazy.nvim.git',
        '--branch=stable', -- latest stable release
        lazypath,
    }
end

vim.opt.rtp:prepend(lazypath)

-- Plugins Config
require('lazy').setup {
    {
        -- Telescope needed fuzzy finding lib
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
    },
    {
        -- fuzzy finding EVERYTHING
        'nvim-telescope/telescope.nvim',
        tag = '0.1.5',
        dependencies = {
            'nvim-lua/plenary.nvim',
            'telescope-fzf-native.nvim',
            'nvim-telescope/telescope-media-files.nvim',
            'nvim-telescope/telescope-symbols.nvim',
        },
        opts = function(plugin, opts)
            local actions = require 'telescope.actions'

            return {
                pickers = {
                    colorscheme = {
                        enable_preview = true,
                    },
                    find_files = {
                        hidden = true,
                    },
                    live_grep = {
                        ---@diagnostic disable-next-line: unused-local
                        additional_args = function(opts)
                            return {
                                '--hidden',
                            }
                        end,
                    },
                },
                extensions = {
                    media_files = {
                        find_cmd = 'rg', -- find command (defaults to `fd`)
                    },
                },
                defaults = {
                    dynamic_preview_title = true,
                    mappings = {
                        n = {
                            ['<C-q>'] = actions.smart_send_to_qflist,
                            ['<C-x>'] = actions.delete_buffer,
                        },
                        i = {
                            ['<C-q>'] = actions.smart_send_to_qflist,
                            ['<C-x>'] = actions.delete_buffer,
                        },
                    },
                },
            }
        end,
        config = function(plugin, opts)
            require('telescope').setup(opts)

            require('telescope').load_extension 'fzf'
            require('telescope').load_extension 'aerial'
            require('telescope').load_extension 'media_files'
        end,
        cmd = 'Telescope',
    },
    {
        -- Great Theme
        'folke/tokyonight.nvim',
        lazy = false, -- make sure we load this during startup if it is your main colorscheme
        priority = 1000, -- make sure to load this before all the other start plugins
        opts = function()
            local function get_theme_based_on_time()
                local hour = tonumber(os.date '%H')

                local day_theme = 'day'
                local night_theme = 'moon'

                if hour >= 8 and hour <= 18 then
                    return day_theme
                else
                    return night_theme
                end
            end

            -- local theme = get_theme_based_on_time()
            local theme = 'moon'
            return {
                style = theme,
                styles = {
                    functions = {
                        italic = true,
                    },
                },
                on_colors = function(colors)
                    colors.fg_gutter = '#555f8b'
                end,
                on_highlights = function(hl, c)
                    hl.CursorLineNr = {
                        fg = c.cyan,
                    }
                    -- hl.Visual = {
                    --     bg = '#2f334d',
                    -- }
                    -- hl.ColorColumn = {
                    --     bg = '#222436',
                    -- }
                end,
            }
        end,
        config = function(plugin, opts)
            -- load the colorscheme here
            require('tokyonight').setup(opts)

            vim.cmd [[colorscheme tokyonight]]
        end,
    },
    {
        -- key mapping like Spacemacs
        'folke/which-key.nvim',
        event = 'BufEnter',
        config = function()
            require 'mappings'
        end,
    },
    {
        -- Project files side view
        'nvim-tree/nvim-tree.lua',
        dependencies = {
            'kyazdani42/nvim-web-devicons',
        },
        opts = {
            update_focused_file = {
                enable = true,
            },
            actions = {
                open_file = {
                    quit_on_open = true,
                },
            },
            view = {
                width = 45,
            },
        },
    },
    {
        -- AST for the code
        'nvim-treesitter/nvim-treesitter',
        dependencies = {
            'nvim-treesitter/nvim-treesitter-refactor',
            'nvim-treesitter/nvim-treesitter-context',
            'nvim-treesitter/playground',
        },
        build = ':TSUpdate',
        event = 'BufEnter',
        config = function()
            require 'treesitter'
        end,
    },
    {
        -- you can use the VeryLazy event for things that can
        -- load later and are not important for the initial UI
        -- Nice windows for inputs
        'stevearc/dressing.nvim',
        event = 'VeryLazy',
        opts = {
            input = {
                enabled = true,
                start_in_insert = false,
            },
            select = {
                enabled = false,
            },
        },
    },
    {
        -- No more :noh
        'romainl/vim-cool',
    },
    {
        -- improving % symbol for matches
        'andymass/vim-matchup',
        init = function()
            -- may set any options here
            vim.g.matchup_matchparen_offscreen = { method = 'popup' }
        end,
    },
    {
        -- Treesitter automagic closing symbols
        'windwp/nvim-ts-autotag',
    },
    {
        -- yank history
        'AckslD/nvim-neoclip.lua',
        dependencies = {
            'nvim-telescope/telescope.nvim',
        },
        config = true,
    },
    {
        -- Nice indentation lines
        'lukas-reineke/indent-blankline.nvim',
        main = 'ibl',
        opts = function()
            local highlight = {
                'RainbowRed',
                'RainbowYellow',
                'RainbowBlue',
                'RainbowOrange',
                'RainbowGreen',
                'RainbowViolet',
                'RainbowCyan',
            }

            local hooks = require 'ibl.hooks'
            -- create the highlight groups in the highlight setup hook, so they are reset
            -- every time the colorscheme changes
            hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
                vim.api.nvim_set_hl(0, 'RainbowRed', { fg = '#E06C75' })
                vim.api.nvim_set_hl(0, 'RainbowYellow', { fg = '#E5C07B' })
                vim.api.nvim_set_hl(0, 'RainbowBlue', { fg = '#61AFEF' })
                vim.api.nvim_set_hl(0, 'RainbowOrange', { fg = '#D19A66' })
                vim.api.nvim_set_hl(0, 'RainbowGreen', { fg = '#98C379' })
                vim.api.nvim_set_hl(0, 'RainbowViolet', { fg = '#C678DD' })
                vim.api.nvim_set_hl(0, 'RainbowCyan', { fg = '#56B6C2' })
            end)

            return {
                indent = {
                    highlight = highlight,
                },
            }
        end,
    },
    {
        -- fuzzy finding symbols
        'stevearc/aerial.nvim',
        config = true,
    },
    {
        -- pinning needed files. Signal from noise
        'ThePrimeagen/harpoon',
        branch = 'harpoon2',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = function()
            require 'harpoon_config'
        end,
    },
    {
        'j-hui/fidget.nvim',
        opts = {
            -- options
        },
    },
    {
        -- Colorize the background of the hex codes
        'norcalli/nvim-colorizer.lua',
        config = function()
            require('colorizer').setup()
        end,
    },
    {
        -- Nice tab
        'alvarosevilla95/luatab.nvim',
        dependecies = {
            'kyazdani42/nvim-web-devicons',
        },
        opts = {},
    },
    {
        -- Nice folding based on treesitter
        'kevinhwang91/nvim-ufo',
        dependencies = {
            'kevinhwang91/promise-async',
            'nvim-treesitter/nvim-treesitter',
        },
        main = 'ufo',
        opts = {},
    },
    {
        -- Nice buffer deletion without closing the window
        'famiu/bufdelete.nvim',
    },
    {
        -- git gutter
        'airblade/vim-gitgutter',
    },
    {
        -- completion for vim in lua documentation
        'folke/neodev.nvim',
        opts = {},
    },
    {
        -- Lazygit
        'kdheepak/lazygit.nvim',
        dependencies = {
            'nvim-lua/plenary.nvim',
        },
    },
    {
        -- Nice Comment boxes inside the code
        's1n7ax/nvim-comment-frame',
        -- <leader>cf: Comment one line
        -- <leader>cm: Comment multiple lines
        dependencies = {
            'nvim-treesitter',
        },
        opts = {},
    },
    {
        -- Commenting code easily
        'terrortylor/nvim-comment',
        main = 'nvim_comment',
        opts = {
            line_mapping = '<leader>l;',
            operator_mapping = '<leader>;',
            hook = function()
                require('ts_context_commentstring').update_commentstring()
            end,
        },
        dependencies = {
            'JoosepAlviste/nvim-ts-context-commentstring',
        },
    },
    {
        -- Very useful REPL, specifically for python and Cybersec stuff
        'Vigemus/iron.nvim',
    },
    {
        -- Useful git commit messages on each line
        'rhysd/git-messenger.vim',
    },
    {
        'ruifm/gitlinker.nvim',
        dependencies = {
            'nvim-lua/plenary.nvim',
        },
        opts = {},
    },
    {
        'folke/todo-comments.nvim',
        dependencies = {
            'nvim-lua/plenary.nvim',
        },
        opts = {

            signs = true,
            search = {
                args = {
                    '--color=never',
                    '--no-heading',
                    '--with-filename',
                    '--line-number',
                    '--column',
                    '--hidden',
                },
            },
        },
    },
    {
        -- Package json info
        'vuki656/package-info.nvim',
        dependencies = {
            'MunifTanjim/nui.nvim',
        },
        opts = {},
    },
    {
        -- Coding time dashboard monitoring
        'wakatime/vim-wakatime',
    },
    {
        -- Lualine for nice statusline in the bottom
        'nvim-lualine/lualine.nvim',
        dependencies = {
            'kyazdani42/nvim-web-devicons',
        },
        opts = {
            options = {
                theme = 'tokyonight',
            },
            extensions = { 'quickfix', 'nvim-tree', 'trouble' },
        },
    },
    {
        -- Useful diagnostics tab
        'folke/trouble.nvim',
        dependencies = {
            'nvim-web-devicons',
        },
        opts = {
            icons = true,
            auto_open = false,
            auto_close = false,
            auto_preview = true,
            auto_fold = false,
            use_diagnostic_signs = false,
        },
    },
    {
        -- Annotation Toolkit (documentation)
        'danymat/neogen',
        opts = {
            snippet_engine = 'luasnip',
        },
        dependencies = {
            'nvim-treesitter/nvim-treesitter',
        },
    },
    {
        -- Awesome testing
        'vim-test/vim-test',
        init = function()
            vim.g['test#strategy'] = 'neovim'
            vim.g['test#neovim#term_position'] = 'vert botright'
            vim.g['test#neovim#start_normal'] = 1 -- Start in normal mode so we can scroll
        end,
    },
    {
        -- Nice initial screen
        'goolord/alpha-nvim',
        config = function()
            require('alpha_config').setup()
        end,
    },
    {

        -- Nice LSP INSTALLATION plugin
        'williamboman/mason.nvim',
    },
    {
        -- Bridge between mason and lspconfig
        'williamboman/mason-lspconfig.nvim',
        dependencies = {
            'williamboman/mason.nvim',
            'neovim/nvim-lspconfig',
            'folke/neodev.nvim',
        },
        config = function()
            require 'lsp_config'
        end,
    },
    {
        'L3MON4D3/LuaSnip',
        -- follow latest release.
        version = 'v2.*', -- Replace <CurrentMajor> by the latest released major (first number of latest release)
        -- install jsregexp (optional!).
        build = 'make install_jsregexp',
        dependencies = {
            'rafamadriz/friendly-snippets',
        },
        config = function()
            require 'luasnip_config'
        end,
    },
    {
        'hrsh7th/nvim-cmp',
        dependencies = {
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
            -- Nice Icon for cmp window
            'onsails/lspkind.nvim',
            -- Snippets
            'L3MON4D3/LuaSnip',
            'saadparwaiz1/cmp_luasnip',
        },
        config = function()
            require 'nvim_cmp_config'
        end,
    },
    {
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
    },
    {
        -- GitHub Copilot
        'zbirenbaum/copilot.lua',
        cmd = 'Copilot',
        event = 'InsertEnter',
        opts = {

            suggestion = { enabled = false },
            panel = { enabled = false },
        },
    },
    {
        -- Copilot inside the cmp window
        'zbirenbaum/copilot-cmp',
        dependencies = {
            'copilot.lua',
        },
        config = function()
            require('copilot_cmp').setup {
                formatters = {
                    insert_text = require('copilot_cmp.format').remove_existing,
                },
            }
        end,
    },
    {
        'stevearc/conform.nvim',
        opts = {
            formatters_by_ft = {
                lua = { 'stylua' },
                typescript = { { 'prettierd', 'prettier' } },
                javascript = { { 'prettierd', 'prettier' } },
                python = { { 'ruff_format', 'black' } },
                yaml = { 'yamlft' },
            },
            format_on_save = {
                timeout_ms = 500,
                lsp_fallback = true,
            },
        },
    },
    {
        -- easier jumps on the same line
        'jinh0/eyeliner.nvim',
        opts = {
            highlight_on_key = true, -- show highlights only after keypress
            dim = true, -- dim all other characters if set to true (recommended!)
        },
    },
    {
        'mechatroner/rainbow_csv',
    },
    {
        -- Awesome single-directory file explorer
        'stevearc/oil.nvim',
        opts = {
            default_file_explorer = true,
            view_options = {
                -- Show files and directories that start with "."
                show_hidden = true,
            },
        },
        dependencies = {
            'nvim-tree/nvim-web-devicons',
        },
    },
    {
        -- GREAT marks navigation through your code
        'LeonHeidelbach/trailblazer.nvim',
        opts = {
            auto_save_trailblazer_state_on_exit = true,
            auto_load_trailblazer_state_on_enter = true,
        },
    },
    {
        -- Forces me to improve my navigation workflow inside neovim
        'm4xshen/hardtime.nvim',
        dependencies = { 'MunifTanjim/nui.nvim', 'nvim-lua/plenary.nvim' },
        opts = {},
    },
}
