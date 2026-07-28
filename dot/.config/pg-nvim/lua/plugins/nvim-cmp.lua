return {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-path',
        -- Nice icons in the cmp menu (incl. the Copilot symbol). Mirrors main nvim.
        'onsails/lspkind.nvim',
        -- Schema-aware SQL completion. Introspects the connection set on `b:db`
        -- (wired from $PG_NVIM_SERVICE in config/vim.lua) and caches the result
        -- per session — no per-keystroke queries. Pulls in vim-dadbod.
        { 'kristijanhusak/vim-dadbod-completion', dependencies = { 'tpope/vim-dadbod' } },
    },
    config = function()
        local cmp = require 'cmp'
        local lspkind = require 'lspkind'

        -- Mappings mirror the main nvim config (C-n/C-p/C-d/C-f/C-e/C-y/C-Space),
        -- with one change: macOS eats <C-Space> (input-source switch), so C-n/C-p
        -- double as the manual trigger — they OPEN the menu when it's closed and
        -- navigate when it's open. So the keys you already know just work.
        local mapping = cmp.mapping.preset.insert {
            ['<C-n>'] = cmp.mapping(function()
                if cmp.visible() then
                    cmp.select_next_item { behavior = cmp.SelectBehavior.Insert }
                else
                    cmp.complete()
                end
            end, { 'i' }),
            ['<C-p>'] = cmp.mapping(function()
                if cmp.visible() then
                    cmp.select_prev_item { behavior = cmp.SelectBehavior.Insert }
                else
                    cmp.complete()
                end
            end, { 'i' }),
            ['<C-d>'] = cmp.mapping.scroll_docs(-4),
            ['<C-f>'] = cmp.mapping.scroll_docs(4),
            ['<C-e>'] = cmp.mapping.abort(),
            ['<C-y>'] = cmp.mapping.confirm { behavior = cmp.ConfirmBehavior.Replace, select = true },
            -- Kept for parity / if you remap the macOS shortcut; harmless otherwise.
            ['<C-Space>'] = cmp.mapping.complete(),
        }

        cmp.setup {
            completion = { completeopt = 'menu,menuone,noselect' },
            mapping = mapping,
            -- Icon formatting mirrors main nvim (symbol mode + Copilot glyph).
            formatting = {
                format = lspkind.cmp_format {
                    mode = 'symbol',
                    maxwidth = 50,
                    ellipsis_char = '...',
                    symbol_map = { Copilot = '' },
                },
                expandable_indicator = true,
            },
            window = {
                completion = cmp.config.window.bordered(),
                documentation = cmp.config.window.bordered(),
            },
            -- vim-dadbod-completion is registered GLOBALLY (not via a FileType
            -- autocmd): cmp lazy-loads on InsertEnter, after the sql buffer's
            -- FileType already fired, so a per-buffer setup would miss it. The
            -- source self-gates — it returns nothing unless `b:db` is set
            -- (wired from $PG_NVIM_SERVICE in config/vim.lua). Schema, Copilot and
            -- path are the primary group; the buffer source is a second-tier
            -- fallback so words from the recalled-query history block don't bury
            -- real schema/suggestions.
            sources = cmp.config.sources({
                { name = 'vim-dadbod-completion' },
                { name = 'copilot' },
                { name = 'path', option = { show_hidden_files = true } },
            }, {
                { name = 'buffer', keyword_length = 3 },
            }),
        }
    end,
}
