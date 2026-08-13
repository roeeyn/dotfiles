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
        -- Only the two standard states: [-]/[>]/[<] are BuJo vault semantics
        -- owned by bujo-nvim's migrate.lua and strike.lua, meaningless here.
        checkbox = {
            unchecked = { icon = '󰄱 ' },
            checked = { icon = '󰱒 ' },
        },
    },
}
