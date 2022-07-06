-- Helps to gf to find files in the current buffer
-- TODO: Fix because error
-- vim.opt.path = vim.opt.path .. '**'

-- Needed settings for font issues (Telescope)
vim.opt.encoding = 'utf-8'

-- Column limit 120
vim.opt.colorcolumn = '120'

-- Cursor line
vim.opt.cursorline = true

-- Move to underscore words
vim.opt.iskeyword = vim.opt.iskeyword - '_'

-- Reads changes from external events
vim.opt.autoread = true

-- Needed for cool colors
-- TODO: Verify if this is needed for tokyo
-- vim.opt.termguicolors = true

-- Is how many columns of whitespace a tab keypress or a backspace keypress is worth
vim.opt.tabstop = 2
vim.opt.softtabstop = 2

-- How many columns of whitespace a level of identation is worth
vim.opt.shiftwidth = 2

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

-- Highlight trailing spaces
vim.cmd([[
highlight ExtraWhitespace ctermbg=red guibg=red
autocmd ColorScheme * highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
]])

-- Show quotes in JSON
vim.opt.conceallevel = 0

print('holi')
