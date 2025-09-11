return {
    'benomahony/oil-git.nvim',
    dependencies = {
        'stevearc/oil.nvim',
    },
    config = function()
        require('oil-git').setup {
            -- Add your configuration options here
            -- See the plugin's README for available options
        }
    end,
}
