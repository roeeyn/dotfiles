return {
    'terrortylor/nvim-comment',
    main = 'nvim_comment',
    config = function()
        require('nvim_comment').setup {
            operator_mapping = '<leader>;',
            hook = function()
                require('ts_context_commentstring').update_commentstring()
            end,
        }
    end,
    dependencies = {
        'JoosepAlviste/nvim-ts-context-commentstring',
    },
}
