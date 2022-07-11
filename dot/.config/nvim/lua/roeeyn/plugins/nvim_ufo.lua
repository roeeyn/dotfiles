-- Nvim UFO (Folding)

vim.wo.foldcolumn = '1'
vim.wo.foldlevel = 99 -- feel free to decrease the value
vim.wo.foldenable = false

require('ufo').setup({
    provider_selector = function(bufnr, filetype)
        return {'treesitter', 'indent'}
    end
})
