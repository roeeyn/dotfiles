return {
    'terrortylor/nvim-comment',
    main = 'nvim_comment',
    config = function()
        require('ts_context_commentstring').setup {
            enable_autocmd = false,
        }
        require('nvim_comment').setup {
            operator_mapping = '<leader>;',
            hook = function()
                require('ts_context_commentstring.internal').update_commentstring()
            end,
        }
    end,
    dependencies = {
        'JoosepAlviste/nvim-ts-context-commentstring',
    },
}
