return {
    'terrortylor/nvim-comment',
    main = 'nvim_comment',
    opts = {
        operator_mapping = '<leader>;',
        hook = function()
            require('ts_context_commentstring').update_commentstring()
        end,
    },
    dependencies = {
        'JoosepAlviste/nvim-ts-context-commentstring',
    },
}
