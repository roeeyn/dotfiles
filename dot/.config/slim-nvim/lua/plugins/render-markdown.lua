return {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    ft = 'markdown',
    opts = {
        heading = {
            icons = { '󰎤 ', '󰎧 ', '󰎪 ', '󰎭 ', '󰎱 ', '󰎳 ' },
        },
        bullet = {
            icons = { '●', '○', '◆', '◇' },
        },
        checkbox = {
            unchecked = { icon = '󰄱 ' },
            checked = { icon = '󰱒 ' },
        },
    },
}
