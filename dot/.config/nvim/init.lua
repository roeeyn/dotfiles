----------------------------------------------------------------------
--                  Main NeoVim configuration file                  --
----------------------------------------------------------------------
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
}
