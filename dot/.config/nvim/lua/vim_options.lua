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


print('holi')
