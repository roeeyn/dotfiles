return {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-path',
    },
    config = function()
        local cmp = require 'cmp'

        cmp.register_source('fuzzy_path', require('cmp_fuzzy_path').new())

        cmp.setup {
            completion = {
                completeopt = 'menu,menuone,noselect',
            },
            mapping = cmp.mapping.preset.insert {
                ['<C-n>'] = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Insert },
                ['<C-p>'] = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Insert },
                ['<C-e>'] = cmp.mapping.abort(),
                ['<C-y>'] = cmp.mapping.confirm {
                    behavior = cmp.ConfirmBehavior.Replace,
                    select = true,
                },
                ['<C-Space>'] = cmp.mapping.complete(),
            },
            sources = cmp.config.sources({
                { name = 'fuzzy_path' },
                {
                    name = 'path',
                    option = {
                        show_hidden_files = true,
                    },
                },
            }, {
                { name = 'buffer', keyword_length = 3 },
            }),
        }
    end,
}
