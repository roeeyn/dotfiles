require('packer').startup(function(use)
    -- useful hover information over different code parts

    -- TODO: Add format configuration
    use {
        'stevearc/conform.nvim',
        config = function()
            require('conform').setup()
        end,
    }
end)
