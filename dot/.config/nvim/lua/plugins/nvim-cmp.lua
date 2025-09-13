return {
    'hrsh7th/nvim-cmp',
    dependencies = {
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-cmdline',
        'hrsh7th/cmp-nvim-lsp-signature-help',
        'hrsh7th/cmp-git',
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-nvim-lua',
        'hrsh7th/cmp-path',
        'hrsh7th/cmp-calc',
        -- 'hrsh7th/cmp-emoji',
        'ray-x/cmp-treesitter',
        -- Nice Icon for cmp window
        'onsails/lspkind.nvim',
        -- Snippets
        'L3MON4D3/LuaSnip',
        'saadparwaiz1/cmp_luasnip',
    },
    config = function()
        -- Setup nvim-cmp.
        local cmp = require 'cmp'
        local lspkind = require 'lspkind'

        if cmp == nil then
            return
        end

        cmp.setup {
            snippet = {
                expand = function(args)
                    require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
                end,
            },
            formatting = {
                format = lspkind.cmp_format {
                    mode = 'symbol', -- show only symbol annotations
                    maxwidth = 50, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
                    ellipsis_char = '...', -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)

                    -- The function below will be called before any actual modifications from lspkind
                    -- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
                    before = function(entry, vim_item)
                        -- ...
                        return vim_item
                    end,
                    symbol_map = { Copilot = '' },
                },
                expandable_indicator = true,
            },
            window = {
                completion = cmp.config.window.bordered(),
                documentation = cmp.config.window.bordered(),
            },
            mapping = cmp.mapping.preset.insert {
                ['<C-n>'] = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Insert },
                ['<C-p>'] = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Insert },
                ['<C-d>'] = cmp.mapping.scroll_docs(-4),
                ['<C-f>'] = cmp.mapping.scroll_docs(4),
                ['<C-e>'] = cmp.mapping.abort(),
                ['<C-y>'] = cmp.mapping(
                    cmp.mapping.confirm {
                        behavior = cmp.ConfirmBehavior.Replace,
                        select = true,
                    },
                    { 'i', 'c' }
                ),

                ['<c-space>'] = cmp.mapping {
                    i = cmp.mapping.complete(),
                    c = function(
                        _ --[[fallback]]
                    )
                        if cmp.visible() then
                            if not cmp.confirm { select = true } then
                                return
                            end
                        else
                            cmp.complete()
                        end
                    end,
                },
            },
            sources = cmp.config.sources({
                { name = 'calc' },
                { name = 'luasnip' }, -- For luasnip users.
                { name = 'nvim_lsp' },
                { name = 'nvim_lsp_signature_help' },
                { name = 'nvim_lua' },
                { name = 'path' },
                -- { name = 'emoji' },
                { name = 'spell' },
                { name = 'treesitter' },
                { name = 'copilot' },
            }, {
                { name = 'buffer', keyword_length = 3 },
            }),
        }

        -- Set configuration for specific filetype.

        -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
        cmp.setup.cmdline({ '/', '?' }, {
            mapping = cmp.mapping.preset.cmdline(),
            sources = {
                { name = 'buffer' },
            },
        })

        -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
        cmp.setup.cmdline(':', {
            mapping = cmp.mapping.preset.cmdline(),
            sources = cmp.config.sources({
                { name = 'path' },
            }, {
                { name = 'cmdline' },
            }),
        })
    end,
}
