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

-- Packer compile whenever plugins.lua is updated
local packer_ag = vim.api.nvim_create_augroup('packer-user-config', { clear = true })

vim.api.nvim_create_autocmd('BufWritePost', {
    group = packer_ag,
    pattern = 'plugins.lua',
    command = 'source <afile> | PackerCompile',
})

-- Highlight Yanked text
local yank_ag = vim.api.nvim_create_augroup('YankHighlight', { clear = true })

vim.api.nvim_create_autocmd('TextYankPost', {
    group = yank_ag,
    callback = function()
        vim.highlight.on_yank { timeout = 250, on_visual = true }
    end,
})
