vim.api.nvim_create_autocmd('FileType', {
    -- To add more files, transform the string to table {}
    pattern = 'python',
    callback = function()
        vim.schedule(function()
            vim.bo.tabstop = 4
            vim.bo.shiftwidth = 4
            vim.bo.softtabstop = 4
        end)
    end
})

-- Adding comment string for elixir patterns
local set_comment_string_ag = vim.api.nvim_create_augroup("set-commentstring-ag", { clear = true })

-- When you enter a new buffer
vim.api.nvim_create_autocmd('BufEnter', {
    group = set_comment_string_ag,
    pattern = 'elixir',
    callback = function()
        vim.api.nvim_buf_set_option(0, 'commentstring', '# %s')
    end
})

-- When you've changed the name of a file opened in a buffer and the file type may have changed
vim.api.nvim_create_autocmd('BufFilePost', {
    group = set_comment_string_ag,
    pattern = 'elixir',
    callback = function()
        vim.api.nvim_buf_set_option(0, 'commentstring', '# %s')
    end
})

-- Packer compile whenever plugins.lua is updated
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerCompile
  augroup end
]])

-- Highlight Yanked text
vim.cmd([[
  augroup highlight_yank
    autocmd!
    autocmd TextYankPost * silent! lua vim.highlight.on_yank {higroup=(vim.fn['hlexists']('HighlightedyankRegion') > 0 and 'HighlightedyankRegion' or 'IncSearch'), timeout=250}
  augroup END
]])