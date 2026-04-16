local filetypes = {
    'bash',
    'css',
    'dockerfile',
    'elixir',
    'heex',
    'html',
    'javascript',
    'json',
    'lua',
    'markdown',
    'python',
    'typescript',
    'vim',
    'vimdoc',
    'yaml',
}

return {
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    build = ':TSUpdate',
    config = function()
        require('nvim-treesitter').install(filetypes)

        vim.api.nvim_create_autocmd('FileType', {
            pattern = filetypes,
            callback = function()
                vim.treesitter.start()
                vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end,
        })
    end,
}
