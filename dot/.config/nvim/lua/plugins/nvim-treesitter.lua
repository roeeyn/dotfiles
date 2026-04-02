return {
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    build = ':TSUpdate',
    -- build = function()
    --     require('nvim-treesitter').update()
    -- end,
    -- config = function()
    --     require('nvim-treesitter').setup {}
    --     vim.api.nvim_create_autocmd('FileType', {
    --         callback = function(args)
    --             pcall(vim.treesitter.start, args.buf)
    --         end,
    --     })
    -- end,
}
