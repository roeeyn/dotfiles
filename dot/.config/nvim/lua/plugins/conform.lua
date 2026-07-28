return {
    'stevearc/conform.nvim',
    opts = {
        formatters_by_ft = {
            lua = { 'stylua' },
            typescript = { 'prettier', 'prettierd', 'biome', stop_after_first = true },
            javascript = { 'biome', 'prettierd', 'prettier', stop_after_first = true },
            python = { 'ruff_format', 'black', stop_after_first = true },
            elixir = { 'mix' },
            yaml = { 'yamlft' },
        },
        formatters = {
            -- Default `cwd` only resolves when a `mix.exs` is found upward, so
            -- standalone `.exs` scripts fall through to Neovim's cwd. Widen the
            -- search to `.formatter.exs` and finally the buffer's own dir so
            -- `mix format` always has a stable working directory.
            mix = {
                cwd = function(self, ctx)
                    local util = require 'conform.util'
                    return util.root_file { 'mix.exs', '.formatter.exs' }(self, ctx) or vim.fs.dirname(ctx.filename)
                end,
            },
        },
        -- format_on_save = {
        --     timeout_ms = 500,
        --     lsp_fallback = true,
        -- },
    },
}
