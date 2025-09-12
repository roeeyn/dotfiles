-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Needed settings for font issues (Telescope)
vim.opt.encoding = 'utf-8'

-- Cursor line
vim.opt.cursorline = true

-- Move to underscore words
vim.opt.iskeyword = vim.opt.iskeyword - '_'

-- Reads changes from external events
vim.opt.autoread = true

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

-- Winbar Config (Top right with modifier)
vim.opt.winbar = '%=%m %f'

-- Split vertically to the right
vim.opt.splitright = true

-- Case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Clearing red for empty spaces in scratch
local empty_spaces_ag = vim.api.nvim_create_augroup('highlight-trailing-spaces', { clear = true })

vim.cmd 'highlight ExtraWhitespace ctermbg=red guibg=red'

vim.api.nvim_create_autocmd('FileType', {
    group = empty_spaces_ag,
    pattern = '*',
    command = [[match ExtraWhitespace /\s\+$/]],
})

vim.api.nvim_create_autocmd('FileType', {
    group = empty_spaces_ag,
    pattern = { 'help', 'mason', 'fugitive', 'lspinfo', 'TelescopePrompt', 'TelescopeResults' },
    command = 'match none',
})

-- Highlight Yanked text
local yank_ag = vim.api.nvim_create_augroup('YankHighlight', { clear = true })

vim.api.nvim_create_autocmd('TextYankPost', {
    group = yank_ag,
    callback = function()
        vim.highlight.on_yank { timeout = 250, on_visual = true }
    end,
})

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
