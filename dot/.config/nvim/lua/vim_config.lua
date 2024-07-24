----------------------------------------------------------------------
--                    Vim Global Configurations                     --
----------------------------------------------------------------------

-- Nvim Tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Needed settings for font issues (Telescope)
vim.opt.encoding = 'utf-8'

-- Highlight search
vim.opt.hlsearch = true

-- Column limit 120
vim.opt.colorcolumn = '98'

-- Cursor line
vim.opt.cursorline = true

-- Move to underscore words
vim.opt.iskeyword = vim.opt.iskeyword - '_'

-- Reads changes from external events
vim.opt.autoread = true

-- Needed for cool colors
vim.opt.termguicolors = true

-- Is how many columns of whitespace a tab keypress or a backspace keypress is worth
vim.opt.tabstop = 4
vim.opt.softtabstop = 4

-- How many columns of whitespace a level of identation is worth
vim.opt.shiftwidth = 4

-- Use spaces instead of \t
vim.opt.expandtab = true

-- The cursor is moved onto the window with 'scrolloff' screen lines around it
vim.opt.scrolloff = 8

-- Set line numbers
vim.opt.number = true

-- Set relative line numbers
vim.opt.relativenumber = true

-- Ignore folders in searche
vim.opt.wildignore = '*/node_modules/*,*/target/*,*/tmp/*,*/venv/*'

-- Show quotes in JSON
vim.opt.conceallevel = 0

-- Gitgutter to catch the changes faster
vim.opt.updatetime = 100
vim.g.gitgutter_map_keys = 0

-- Timeout for whichkey to trigger
vim.opt.timeoutlen = 600

-- DoGe Global parameters
vim.g.doge_enable_mappings = 0
vim.g.doge_doc_standard_python = 'google'
vim.g.doge_comment_jump_modes = { 'n', 's' }

-- Winbar Config (Top right with modifier)
vim.opt.winbar = '%=%m %f'

-- Split vertically to the right
vim.opt.splitright = true

-- Snippets
vim.g.snippets = 'luasnip'
vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }

-- Case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Folding configurations
vim.o.foldcolumn = '1'
vim.o.foldlevel = 99 -- feel free to decrease the value
vim.o.foldlevelstart = 99
vim.o.foldenable = true

-- Using ufo provider need remap `zR` and `zM`. If Neovim is 0.6.1, remap yourself
-- vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
-- vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)

----------------------------------------------------------------------
--                     Autocommands Generation                      --
----------------------------------------------------------------------

vim.api.nvim_create_autocmd('FileType', {
    -- To add more files, transform the string to table {}
    pattern = 'python',
    callback = function()
        vim.schedule(function()
            vim.bo.tabstop = 4
            vim.bo.shiftwidth = 4
            vim.bo.softtabstop = 4
        end)
    end,
})

-- Clearing red for empty spaces in scratch
local empty_spaces_ag = vim.api.nvim_create_augroup('highlight-trailing-spaces', { clear = true })

vim.cmd 'highlight ExtraWhitespace ctermbg=red guibg=red'

vim.api.nvim_create_autocmd('FileType', {
    group = empty_spaces_ag,
    pattern = '*',
    command = [[match ExtraWhitespace /\s\+$/]],
})

local alpha_filetype = 'dashboard'

vim.api.nvim_create_autocmd('FileType', {
    group = empty_spaces_ag,
    pattern = { alpha_filetype, 'help', 'mason', 'fugitive', 'lspinfo', 'TelescopePrompt', 'TelescopeResults' },
    command = 'match none',
})

vim.api.nvim_create_autocmd('TermOpen', {
    group = empty_spaces_ag,
    pattern = '*',
    command = 'match none',
})

vim.api.nvim_create_autocmd('User', {
    group = empty_spaces_ag,
    pattern = 'AlphaReady',
    command = 'set filetype=' .. alpha_filetype,
})

-- Adding comment string for elixir patterns
local set_comment_string_ag = vim.api.nvim_create_augroup('set-commentstring-ag', { clear = true })

-- When you enter a new buffer
vim.api.nvim_create_autocmd('BufEnter', {
    group = set_comment_string_ag,
    pattern = 'elixir',
    callback = function()
        vim.api.nvim_buf_set_option(0, 'commentstring', '# %s')
    end,
})

-- When you've changed the name of a file opened in a buffer and the file type may have changed
vim.api.nvim_create_autocmd('BufFilePost', {
    group = set_comment_string_ag,
    pattern = 'elixir',
    callback = function()
        vim.api.nvim_buf_set_option(0, 'commentstring', '# %s')
    end,
})

-- Setting comment string for prisma
vim.api.nvim_create_autocmd('FileType', {
    group = set_comment_string_ag,
    pattern = 'prisma',
    callback = function()
        vim.api.nvim_buf_set_option(0, 'commentstring', '// %s')
    end,
})

-- Highlight Yanked text
local yank_ag = vim.api.nvim_create_augroup('YankHighlight', { clear = true })

vim.api.nvim_create_autocmd('TextYankPost', {
    group = yank_ag,
    callback = function()
        vim.highlight.on_yank { timeout = 250, on_visual = true }
    end,
})

----------------------------------------------------------------------
--                List of all the keymaps registered                --
----------------------------------------------------------------------

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

local function map(mode, shortcut, command)
    vim.api.nvim_set_keymap(mode, shortcut, command, {
        noremap = true,
        -- TODO: Verify if this is ok
        -- silent = true,
    })
end

local function vmap(shortcut, command)
    map('v', shortcut, command)
end

local function xmap(shortcut, command)
    map('x', shortcut, command)
end

-- Moving lines up and down in visual mode
vmap('J', ":m '>+1<CR>gv=gv")
vmap('K', ":m '<-2<CR>gv=gv")

-- Yanking in visual mode to clipboard
xmap('<leader>y', '"+y<CR>')
