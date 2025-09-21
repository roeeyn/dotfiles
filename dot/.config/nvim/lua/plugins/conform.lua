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
        -- format_on_save = {
        --     timeout_ms = 500,
        --     lsp_fallback = true,
        -- },
    },
}
