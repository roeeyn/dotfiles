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
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    {
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
        end,
        cmd = 'Telescope',
    },
    {
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
        'folke/which-key.nvim',
        event = 'BufEnter',
        config = function()
            require 'mappings'
        end,
    },
}
