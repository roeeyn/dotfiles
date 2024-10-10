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
        -- REPL for elixir
        'jpalardy/vim-slime',
        init = function()
            vim.g.slime_target = 'tmux'
        end,
    },
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
        event = 'VeryLazy',
        opts = {},
        keys = {
            {
                '<leader>?',
                function()
                    require('which-key').show { global = false }
                end,
                desc = 'Buffer Local Keymaps (which-key)',
            },
            { '<leader>b', group = 'Buffers' },
            { '<leader>bD', '<cmd>%bd|e#|bd#<cr>', desc = 'Close other buffers' },
            { '<leader>bb', '<cmd>Telescope buffers<cr>', desc = 'Telescope buffers' },
            { '<leader>bd', '<cmd>Bdelete<cr>', desc = 'Soft remove buffer' },
            { '<leader>bl', '<C-^>', desc = 'Last buffer' },
            { '<leader>bn', '<cmd>bn<cr>', desc = 'Next Buffer' },
            { '<leader>bp', '<cmd>bp<cr>', desc = 'Previous buffer' },
            { '<leader>bx', '<cmd>bd<cr>', desc = 'Hard remove buffer' },
            { '<leader>c', group = 'Code' },
            { '<leader>c0', '<cmd>lua require("conform").format()<cr>', desc = '[Format] Buffer' },
            { '<leader>cR', '<cmd>lua vim.lsp.buf.rename()<cr>', desc = '[LSP] Rename definition' },
            { '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<cr>', desc = '[LSP] Diagn. Action' },
            { '<leader>cc', '<cmd>cclose<cr>', desc = '[Quickfix] Close' },
            { '<leader>cd', '<cmd>lua vim.lsp.buf.declaration()<cr>', desc = '[LSP] Go To Declaration' },
            { '<leader>cf', 'lua require("nvim-comment-frame").add_comment()', desc = '[Comment] Frame one line' },
            { '<leader>cg', '<cmd>cc<cr>', desc = '[Quickfix] Go to current element' },
            { '<leader>cl', '<cmd>Telescope quickfix<cr>', desc = '[Quickfix] List quickfix elements' },
            { '<leader>cm', '<cmd>lua require("nvim-comment-frame").add_multiline_comment()<CR>', desc = '[Comment] Frame multiple lines' },
            { '<leader>cn', '<cmd>cnext<cr>', desc = '[Quickfix] Go to next element' },
            { '<leader>co', '<cmd>copen<cr>', desc = '[Quickfix] Open quickfix list' },
            { '<leader>cp', '<cmd>cprevious<cr>', desc = '[Quickfix] Go to prev element' },
            { '<leader>cs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', desc = '[LSP] Signature help' },
            { '<leader>ct', '<cmd>lua require("hover").hover()<cr>', desc = '[LSP] Hover Info' },
            { '<leader>cx', '<cmd>lua vim.fn.setqflist({})<cr>', desc = '[Quickfix] Clear quickfix' },
            { '<leader>cy', 'yypk <cmd>CommentToggle<CR>j', desc = '[Misc] Duplicate and comment' },
            { '<leader>d', group = 'Debug/Diag.' },
            { '<leader>db', '<cmd>lua require"dap".toggle_breakpoint()<cr>', desc = '[Debug] Toggle Breakpoint' },
            { '<leader>dc', '<cmd>lua require"dap".continue()<cr>', desc = '[Debug] Start/Continue' },
            { '<leader>dd', '<cmd>Neogen<cr>', desc = '[Neogen] Generate Annotation' },
            { '<leader>dh', "<cmd>lua require'dap.ui.widgets'.hover()<cr>", desc = '[Debug] Hover' },
            { '<leader>dn', '<cmd>lua vim.diagnostic.goto_next()<cr>', desc = '[Diag] Go Next' },
            { '<leader>do', '<cmd>TroubleToggle<cr>', desc = '[Trouble] Open' },
            { '<leader>dp', '<cmd>lua vim.diagnostic.goto_prev()<cr>', desc = '[Diag] Go Prev' },
            { '<leader>dr', '<cmd>TroubleRefresh<CR>', desc = '[Trouble] Manual refresh' },
            { '<leader>ds', group = 'Debugging' },
            { '<leader>dsd', '<cmd>lua require"dap".down()<cr>', desc = 'Down' },
            { '<leader>dsi', '<cmd>lua require"dap".step_into()<cr>', desc = 'Step into' },
            { '<leader>dso', '<cmd>lua require"dap".step_out()<cr>', desc = 'Step out' },
            { '<leader>dst', '<cmd>lua require"dap".stop()<cr>', desc = 'Stop' },
            { '<leader>dsu', '<cmd>lua require"dap".up()<cr>', desc = 'Up' },
            { '<leader>dsv', '<cmd>lua require"dap".step_over()<cr>', desc = 'Step over' },
            { '<leader>dt', group = 'Telescope DAP' },
            { '<leader>dtb', '<cmd>Telescope dap list_breakpoints<cr>', desc = '[DAP] List breakpoints' },
            { '<leader>dtc', '<cmd>Telescope dap commands<cr>', desc = '[DAP] List commands' },
            { '<leader>dtf', '<cmd>Telescope dap frames<cr>', desc = '[DAP] List frames' },
            { '<leader>dtv', '<cmd>Telescope dap variables<cr>', desc = '[DAP] List variables' },
            { '<leader>du', "<cmd>lua require'dapui'.()<CR>", desc = '[Debug] Toggle UI' },
            { '<leader>e', group = 'Errors' },
            { '<leader>eO', '<cmd>lua require("telescope.builtin").diagnostics{}<cr>', desc = 'Open diagnostics' },
            { '<leader>ec', '<cmd>lclose<cr>', desc = 'Close location list' },
            { '<leader>el', '<cmd>lua vim.diagnostic.open_float()<cr>', desc = 'Open diagnostic float' },
            { '<leader>en', '<cmd>lnext<cr>', desc = 'Next location list item' },
            { '<leader>eo', '<cmd>lua require("telescope.builtin").diagnostics{bufnr=0}<cr>', desc = 'Open current buffer diagnostics' },
            { '<leader>ep', '<cmd>lprevious<cr>', desc = 'Prev location list item' },
            { '<leader>f', group = 'File/Find/Telescope' },
            { '<leader>f/', '<cmd>Telescope current_buffer_fuzzy_find<cr>', desc = '[Telescope] Fuzzy search in buffer' },
            { '<leader>fS', '<cmd>wa<cr>', desc = '[File] Save all buffers' },
            { '<leader>fa', '<cmd>Telescope aerial<cr>', desc = '[Telescope] aerial (symbols)' },
            { '<leader>fb', '<cmd>Telescope builtin<cr>', desc = '[Telescope] builtin' },
            { '<leader>fc', '<cmd>Telescope quickfix<cr>', desc = '[Telescope] quickfix' },
            { '<leader>fe', '<cmd>Telescope symbols<cr>', desc = '[Telescope] emojis' },
            { '<leader>ff', '<cmd>Telescope find_files<cr>', desc = '[Telescope] Find file' },
            { '<leader>fg', '<cmd>Telescope grep_string<cr>', desc = '[Telescope] Grep string' },
            { '<leader>fh', '<cmd>Telescope help_tags<cr>', desc = '[Telescope] Find help tags' },
            { '<leader>fk', '<cmd>Telescope keymaps<cr>', desc = '[Telescope] Find keymaps' },
            { '<leader>fr', '<cmd>Telescope resume<cr>', desc = '[Telescope] Resume' },
            { '<leader>fs', '<cmd>w<cr>', desc = '[File] Save current buffer' },
            { '<leader>ft', '<cmd>TodoTelescope<cr>', desc = '[Telescope] Find ToDos' },
            { '<leader>g', group = 'Git/GitHub/GoTo' },
            { '<leader>gC', '<cmd>vsplit | term gh pr create<cr>', desc = '[GitHub] Create Pull Request' },
            { '<leader>gD', '<cmd>GitGutterDiffOrig<cr>', desc = '[Git] Diff Hunk' },
            { '<leader>gT', '<cmd>Telescope lsp_type_definitions<cr>', desc = '[GoTo] LSP type definitions' },
            { '<leader>gb', '<cmd>BlameToggle<cr>', desc = '[Git] Blame' },
            { '<leader>gd', '<cmd>Telescope lsp_definitions<cr>', desc = '[GoTo] LSP definitions' },
            { '<leader>gi', '<cmd>Telescope lsp_implementations<cr>', desc = '[GoTo] LSP implementations' },
            { '<leader>gm', desc = '[Git] See Git Message' },
            { '<leader>gn', '<cmd>GitGutterNextHunk<cr>', desc = '[Git] Next Hunk' },
            { '<leader>go', '<cmd>GitGutterPreviewHunk<cr>', desc = '[Git] Preview Hunk' },
            { '<leader>gp', '<cmd>GitGutterPrevHunk<cr>', desc = '[Git] Prev Hunk' },
            { '<leader>gr', '<cmd>Telescope lsp_references<cr>', desc = '[GoTo] LSP references' },
            { '<leader>gs', '<cmd>LazyGit<cr>', desc = '[Git] status' },
            { '<leader>gt', '<cmd>Telescope git_status<cr>', desc = '[Git] changed files' },
            { '<leader>gx', '<cmd>GitGutterUndoHunk<cr>', desc = '[Git] Undo Hunk' },
            { '<leader>gy', desc = '[GitHub] Create GitHub Permalink' },
            { '<leader>h', group = 'Harpoon' },
            { '<leader>h;', '<cmd>lua require("harpoon_config").select_file(4)<cr>', desc = 'Go to mark 4' },
            { '<leader>ha', '<cmd>lua require("harpoon_config").add_file()<cr>', desc = 'Add file' },
            { '<leader>hf', '<cmd>lua require("harpoon_config").telescope()<cr>', desc = 'Search in marks' },
            { '<leader>hj', '<cmd>lua require("harpoon_config").select_file(1)<cr>', desc = 'Go to mark 1' },
            { '<leader>hk', '<cmd>lua require("harpoon_config").select_file(2)<cr>', desc = 'Go to mark 2' },
            { '<leader>hl', '<cmd>lua require("harpoon_config").select_file(3)<cr>', desc = 'Go to mark 3' },
            { '<leader>hn', '<cmd>lua require("harpoon_config").next()<cr>', desc = 'Go to next mark' },
            { '<leader>ho', '<cmd>lua require("harpoon_config").quick_ui()<cr>', desc = 'Toggle quick menu' },
            { '<leader>hp', '<cmd>lua require("harpoon_config").prev()<cr>', desc = 'Go to prev mark' },
            { '<leader>hx', '<cmd>lua require("harpoon_config").clear_all()<cr>', desc = 'Clear all marks' },
            { '<leader>l', group = 'Line' },
            { '<leader>l;', desc = 'Toggle line comment' },
            { '<leader>p', group = 'Project' },
            { '<leader>p/', '<cmd>Telescope live_grep<cr>', desc = 'Live grep in whole project' },
            { '<leader>po', '<cmd>Oil<cr>', desc = 'Oil File browser' },
            { '<leader>pt', '<cmd>NvimTreeToggle<cr>', desc = 'Tree File browser' },
            { '<leader>q', group = 'Quit' },
            { '<leader>q1', '<cmd>q!<cr>', desc = 'Force quit' },
            { '<leader>qq', '<cmd>q<cr>', desc = 'Soft quit' },
            { '<leader>r', group = 'Run' },
            { '<leader>rp', '<cmd>vsplit | term .git/hooks/pre-commit<cr>', desc = '[Run] pre-commit' },
            { '<leader>s', group = 'Session' },
            { '<leader>sl', '<cmd>lua require("persistence").load()<cr>', desc = 'Load last session in this project' },
            { '<leader>ss', '<cmd>lua require("persistence").stop()<cr>', desc = "Stop (won't save on exit)" },
            { '<leader>t', group = 'Tab' },
            { '<leader>t1', '<cmd>tabnext 1<cr>', desc = 'Go to tab 1' },
            { '<leader>t2', '<cmd>tabnext 2<cr>', desc = 'Go to tab 2' },
            { '<leader>t3', '<cmd>tabnext 3<cr>', desc = 'Go to tab 3' },
            { '<leader>t4', '<cmd>tabnext 4<cr>', desc = 'Go to tab 4' },
            { '<leader>t5', '<cmd>tabnext 5<cr>', desc = 'Go to tab 5' },
            { '<leader>tO', '<cmd>tabo<cr>', desc = 'Close other tabs' },
            { '<leader>tc', '<cmd>tabnew<cr>', desc = 'Create new tab' },
            { '<leader>tl', '<cmd>tabl<cr>', desc = 'Go to last tab' },
            { '<leader>tn', '<cmd>tabnext<cr>', desc = 'Go to next tab' },
            { '<leader>tp', '<cmd>tabprevious<cr>', desc = 'Go to prev tab' },
            { '<leader>tt', '<cmd>vsplit | term<cr>', desc = 'Create a new terminal in vsplit' },
            { '<leader>tx', '<cmd>tabclose<cr>', desc = 'Close current tab' },
            { '<leader>u', group = 'Testing' },
            { '<leader>uA', '<cmd>vsplit | term pytest<cr>', desc = 'Run pytest globally' },
            { '<leader>uC', '<cmd>CoverageSummary<cr>', desc = 'Coverage popup' },
            { '<leader>uL', '<cmd>vsplit | term pytest --lf<cr>', desc = 'Test last failed' },
            { '<leader>ua', '<cmd>TestSuite<cr>', desc = 'Test all suite' },
            { '<leader>uc', '<cmd>CoverageToggle<cr>', desc = 'Toggle coverage line' },
            { '<leader>uf', '<cmd>TestFile<cr>', desc = 'Test file' },
            { '<leader>ul', '<cmd>TestLast<cr>', desc = 'Test last' },
            { '<leader>ut', '<cmd>TestNearest<cr>', desc = 'Test nearest' },
            { '<leader>v', group = 'Vertical Split' },
            { '<leader>vo', '<cmd>vsplit | Oil<cr>', desc = '[Oil] to the right' },
            { '<leader>w', group = 'Window' },
            { '<leader>w0', '<C-W>=', desc = 'Resize windows equally' },
            { '<leader>wO', '<C-W>o', desc = 'Close other windows' },
            { '<leader>wR', '<cmd>execute "vertical resize " . (&columns * 70 / 100)<cr>', desc = 'Resize window to 70%' },
            { '<leader>wc', '<cmd>close<cr>', desc = 'Close the current window' },
            { '<leader>wh', '<C-W>h', desc = 'Move to left window' },
            { '<leader>wj', '<C-W>j', desc = 'Move to bottom window' },
            { '<leader>wk', '<C-W>k', desc = 'Move to above window' },
            { '<leader>wl', '<C-W>l', desc = 'Move to right window' },
            { '<leader>wo', '<cmd>vertical resize -10<cr>', desc = 'Resize window to the left' },
            { '<leader>wp', '<cmd>vertical resize +10<cr>', desc = 'Resize window to the right' },
            { '<leader>wq', '<cmd>wq<cr>', desc = 'Save and quit window' },
            { '<leader>wr', '<cmd>execute "vertical resize " . (&columns * 30 / 100)<cr>', desc = 'Resize window to 30%' },
            { '<leader>wt', '<cmd>tabe %<cr>', desc = 'Edit current buffer in new tab' },
            { '<leader>y', group = 'Yank' },
            { '<leader>yh', "<cmd>lua require('telescope').extensions.neoclip.default()<cr>", desc = 'Yank history' },
        },
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
        config = function(plugin, opts)
            require('ufo').setup {
                provider_selector = function(bufnr, filetype, buftype)
                    return { 'treesitter', 'indent' }
                end,
            }

            -- Using ufo provider need remap `zR` and `zM`. If Neovim is 0.6.1, remap yourself
            vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
            vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)
        end,
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
            -- line_mapping = '<leader>l;',
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
        -- Create permalinks for the github code at the current cursor
        'ruifm/gitlinker.nvim',
        dependencies = {
            'nvim-lua/plenary.nvim',
        },
        opts = {},
    },
    {
        -- Prettify the TODO comments
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
            sections = {
                lualine_b = {
                    'branch',
                    'diff',
                    "require('arrow.statusline').text_for_statusline_with_icons()",
                    'diagnostics',
                },
            },
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
    -- {
    --     'hrsh7th/nvim-cmp',
    --     dependencies = {
    --         'hrsh7th/cmp-buffer',
    --         'hrsh7th/cmp-cmdline',
    --         'hrsh7th/cmp-nvim-lsp-signature-help',
    --         'hrsh7th/cmp-git',
    --         'hrsh7th/cmp-nvim-lsp',
    --         'hrsh7th/cmp-nvim-lua',
    --         'hrsh7th/cmp-path',
    --         'hrsh7th/cmp-calc',
    --         'hrsh7th/cmp-emoji',
    --         'ray-x/cmp-treesitter',
    --         -- Nice Icon for cmp window
    --         'onsails/lspkind.nvim',
    --         -- Snippets
    --         'L3MON4D3/LuaSnip',
    --         'saadparwaiz1/cmp_luasnip',
    --     },
    --     config = function()
    --         require 'nvim_cmp_config'
    --     end,
    -- },
    {
        'iguanacucumber/magazine.nvim',
        name = 'nvim-cmp',
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
        -- Easy formatting
        'stevearc/conform.nvim',
        opts = {
            formatters_by_ft = {
                lua = { 'stylua' },
                svelte = { 'prettier', 'prettierd', 'biome', stop_after_first = true },
                typescript = { 'prettier', 'prettierd', 'biome', stop_after_first = true },
                javascript = { 'biome', 'prettierd', 'prettier', stop_after_first = true },
                python = { 'ruff_format', 'black', stop_after_first = true },
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
        -- prettify csv files
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
    -- {
    --     -- Forces me to improve my navigation workflow inside neovim
    --     'm4xshen/hardtime.nvim',
    --     dependencies = { 'MunifTanjim/nui.nvim', 'nvim-lua/plenary.nvim' },
    --     opts = {},
    -- },
    {
        -- Git blame UI
        'FabijanZulj/blame.nvim',
        opts = {},
    },
    {
        -- Greate navigation plugin for marks
        'otavioschwanck/arrow.nvim',
        opts = {
            show_icons = true,
            separate_by_branch = true, -- Bookmarks will be separated by git branch
            leader_key = ' M', -- Recommended to be a single key
            buffer_leader_key = ' m', -- Per Buffer Mappings
            mappings = {
                edit = 'e',
                delete_mode = 'd',
                clear_all_items = 'X',
                toggle = 's', -- used as save if separate_save_and_remove is true
                open_vertical = 'v',
                open_horizontal = '-',
                quit = 'q',
                remove = 'x', -- only used if separate_save_and_remove is true
                next_item = '[',
                prev_item = ']',
            },
        },
    },
    -- Lua
    {
        -- saving session (buffers state)
        'folke/persistence.nvim',
        event = 'BufReadPre', -- this will only start session saving when an actual file was opened
        opts = {
            -- add any custom options here
        },
    },
}
