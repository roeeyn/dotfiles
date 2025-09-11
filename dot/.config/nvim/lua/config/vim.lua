-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Cursor line
vim.opt.cursorline = true

-- Move to underscore words
vim.opt.iskeyword = vim.opt.iskeyword - '_'

-- Reads changes from external events
vim.opt.autoread = true

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

-- Clearing red for empty spaces in scratch
local empty_spaces_ag = vim.api.nvim_create_augroup('highlight-trailing-spaces', { clear = true })

vim.cmd 'highlight ExtraWhitespace ctermbg=red guibg=red'

vim.api.nvim_create_autocmd('FileType', {
    group = empty_spaces_ag,
    pattern = '*',
    command = [[match ExtraWhitespace /\s\+$/]],
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

print 'loaded vim correctly'
