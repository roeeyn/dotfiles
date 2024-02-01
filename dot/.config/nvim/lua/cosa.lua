----------------------------------------------------------------------
--                List of plugins used within NeoVim                --
----------------------------------------------------------------------

-- Here's the dotfile of wbthomson, which provides great guidance and plugins variety
-- https://github.com/wbthomason/dotfiles/blob/main/dot_config/nvim/lua/plugins.lua

local install_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'
local is_bootstrap = false

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    is_bootstrap = true
    vim.fn.system { 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path }
    vim.cmd [[packadd packer.nvim]]
end

require('packer').startup(function(use)
    -- Packer can manage itself
    use 'wbthomason/packer.nvim'

    -- My plugins here

    -- Nice windows for inputs
    use {
        'stevearc/dressing.nvim',
        config = function()
            require('dressing').setup {
                input = {
                    enabled = true,
                    start_in_insert = false,
                },
                select = {
                    enabled = true,
                },
            }
        end,
    }

    -- Avoid having to execute :noh whenever a search has been done
    use {
        'romainl/vim-cool',
    }

    use {
        'andymass/vim-matchup',
        setup = function()
            -- may set any options here
            vim.g.matchup_matchparen_offscreen = { method = 'popup' }
        end,
    }

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

    use 'windwp/nvim-ts-autotag'

    -- Clipboard/yank history
    use {
        'AckslD/nvim-neoclip.lua',
        requires = {
            { 'nvim-telescope/telescope.nvim' },
        },
        config = function()
            require('neoclip').setup()
        end,
    }

    -- Package json info
    use {
        'vuki656/package-info.nvim',
        requires = 'MunifTanjim/nui.nvim',
        config = function()
            require('package-info').setup()
        end,
    }

    -- Optimization Plugin
    use 'lewis6991/impatient.nvim'

    -- Nice indentation lines
    use {
        'lukas-reineke/indent-blankline.nvim',
        config = function()
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

            require('ibl').setup {
                indent = {
                    highlight = highlight,
                },
            }
        end,
    }

    -- Very useful REPL, specifically for python and cybersec stuff
    use {
        'Vigemus/iron.nvim',
    }

    -- sidebar to see symbols (function, classes, etc)
    -- attached to telescope for better integration
    use {
        'stevearc/aerial.nvim',
        config = function()
            require('aerial').setup()
        end,
    }

    use {
        'folke/todo-comments.nvim',
        requires = 'nvim-lua/plenary.nvim',
        config = function()
            require('todo-comments').setup {
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
            }
        end,
    }

    -- Theme for neovim
    use {
        'folke/tokyonight.nvim',
        config = function()
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

            require('tokyonight').setup {
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

            vim.cmd [[colorscheme tokyonight]]
        end,
    }

    -- Wakatime, code time tracking
    use 'wakatime/vim-wakatime'

    -- Nvim Treesitter for nice code traversal
    use { -- Highlight, edit, and navigate code
        'nvim-treesitter/nvim-treesitter',
        run = function()
            pcall(require('nvim-treesitter.install').update { with_sync = true })
        end,
        config = function()
            require('nvim-treesitter.configs').setup {
                -- Add languages to be installed here that you want installed for treesitter
                ensure_installed = {
                    'comment',
                    'dockerfile',
                    'git_config',
                    'git_rebase',
                    'gitattributes',
                    'gitcommit',
                    'gitignore',
                    'go',
                    'godot_resource',
                    'gomod',
                    'gosum',
                    'gowork',
                    'graphql',
                    'hjson',
                    'html',
                    'javascript',
                    'json',
                    'json5',
                    'jsonc',
                    'jq',
                    'lua',
                    'markdown',
                    'markdown_inline',
                    'make',
                    'mermaid',
                    'passwd',
                    'python',
                    'rust',
                    'sql',
                    'todotxt',
                    'typescript',
                    'yaml',
                    'vim',
                    'vimdoc',
                },
                highlight = { enable = true },
                -- indent = {enable = true}
                autotag = {
                    enable = true,
                },
                textsubjects = {
                    enable = true,
                    prev_selection = ',', -- (Optional) keymap to select the previous selection
                    keymaps = {
                        ['.'] = 'textsubjects-smart',
                        [';'] = 'textsubjects-container-outer',
                        ['i;'] = 'textsubjects-container-inner',
                    },
                },
                playground = {
                    enable = true,
                },
                matchup = {
                    enable = true,
                    disable = {},
                },
            }
        end,
    }
    use 'nvim-treesitter/playground'

    -- Nvim treesitter context
    use 'nvim-treesitter/nvim-treesitter-context'

    use {
        'kyazdani42/nvim-web-devicons',
        config = function()
            require('nvim-web-devicons').setup()
        end,
    }

    -- Lualine for nice statusline in the bottom
    use {
        'nvim-lualine/lualine.nvim',
        requires = { 'kyazdani42/nvim-web-devicons', opt = true },
        config = function()
            require('lualine').setup {
                options = {
                    theme = 'tokyonight',
                },
            }
        end,
    }

    -- File browser
    use {
        'nvim-tree/nvim-tree.lua',
        requires = { 'kyazdani42/nvim-web-devicons', opt = true },
        config = function()
            require('nvim-tree').setup {
                update_focused_file = {
                    enable = true,
                },
                actions = {
                    open_file = {
                        quit_on_open = true,
                    },
                },
            }
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

    -- Nice Comment boxes inside the code
    use {
        's1n7ax/nvim-comment-frame',
        -- <leader>cf: Comment one line
        -- <leader>cm: Comment multiple lines
        requires = {
            { 'nvim-treesitter' },
        },
        config = function()
            require('nvim-comment-frame').setup()
        end,
    }

    -- Commenting code easily
    use {
        'terrortylor/nvim-comment',
        config = function()
            require('nvim_comment').setup {
                line_mapping = '<leader>l;',
                operator_mapping = '<leader>;',
                function()
                    require('ts_context_commentstring').update_commentstring()
                end,
            }
        end,
    }
    use {
        'JoosepAlviste/nvim-ts-context-commentstring',
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

    -- Git integration
    use 'rhysd/git-messenger.vim'
    use {
        'ruifm/gitlinker.nvim',
        requires = 'nvim-lua/plenary.nvim',
        config = function()
            require('gitlinker').setup()
        end,
    }

    -- Lazygit
    use {
        'kdheepak/lazygit.nvim',
        -- optional for floating window border decoration
        requires = {
            'nvim-lua/plenary.nvim',
        },
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

    -- git gutter
    use 'airblade/vim-gitgutter'

    -- Nice buffer deletion without closing the window
    use 'famiu/bufdelete.nvim'

    use 'nvim-telescope/telescope-symbols.nvim'

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
