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
            checked = {
                icon = '󰱒 ',
                scope_highlight = '@markup.strikethrough',
            },
            -- BuJo states. render-markdown's built-in `todo` custom state
            -- already claims the raw text `[-]`, so it must be overridden
            -- (not shadowed by a new key) to mean "irrelevant" here.
            custom = {
                todo = {
                    raw = '[-]',
                    rendered = '󰩹 ',
                    highlight = 'RenderMarkdownError',
                    scope_highlight = '@markup.strikethrough',
                },
                migrated = {
                    raw = '[>]',
                    rendered = '󰜴 ',
                    highlight = 'RenderMarkdownInfo',
                },
                scheduled = {
                    raw = '[<]',
                    rendered = '󰃰 ',
                    highlight = 'RenderMarkdownHint',
                },
            },
        },
    },
}
