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
            -- No scope_highlight anywhere: it draws ONE extmark across the
            -- item's whole multi-line inline node, striking through the
            -- leading indentation of child lines. The strikethrough for
            -- [x]/[-] blocks is owned by lua/bujo/strike.lua instead, which
            -- marks each line from its bullet to EOL.
            unchecked = { icon = '󰄱 ' },
            checked = { icon = '󰱒 ' },
            -- BuJo states. render-markdown's built-in `todo` custom state
            -- already claims the raw text `[-]`, so it must be overridden
            -- (not shadowed by a new key) to mean "irrelevant" here.
            custom = {
                todo = {
                    raw = '[-]',
                    rendered = '󰩹 ',
                    highlight = 'RenderMarkdownError',
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
