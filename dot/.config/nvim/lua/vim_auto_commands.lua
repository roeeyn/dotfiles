vim.api.nvim_create_autocmd('FileType', {
    pattern = {'python'},
    callback = function()
        vim.schedule(function()
            vim.bo.tabstop = 4
            vim.bo.shiftwidth = 4
            vim.bo.softtabstop = 4
            print('estamos vivos perros')
        end)
    end
})

print('hey')
