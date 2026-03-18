return {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-path',
    },
    config = function()
        local cmp = require 'cmp'
        local cmp_path = require 'cmp_path'

        local original_complete = cmp_path.complete
        cmp_path.complete = function(self, params, callback)
            local option = self:_validate_option(params)
            if not option.show_hidden_files then
                return original_complete(self, params, callback)
            end

            local dirname = self:_dirname(params, option)
            if not dirname then
                return callback()
            end

            self:_candidates(dirname, true, option, function(err, candidates)
                if err then
                    return callback()
                end

                callback(candidates)
            end)
        end

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
