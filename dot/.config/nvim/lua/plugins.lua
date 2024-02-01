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
    -- Telescope needed fuzzy finding lib
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    {
        -- fuzzy finding EVERYTHING
        'nvim-telescope/telescope.nvim',
        tag = '0.1.5',
        dependencies = {
            'nvim-lua/plenary.nvim',
            'telescope-fzf-native.nvim',
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

            local theme = get_theme_based_on_time()
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
}
