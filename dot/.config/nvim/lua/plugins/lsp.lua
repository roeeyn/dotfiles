return {
    'neovim/nvim-lspconfig',
    dependencies = {
        'hrsh7th/cmp-nvim-lsp',
    },
    config = function()
        local capabilities = require('cmp_nvim_lsp').default_capabilities()

        -- Configure all LSP servers
        local servers = {
            -- ansiblels = {},
            bashls = {},
            -- dockerls = {},
            elixirls = {},
            -- emmet_ls = {
            --     filetypes = { 'html', 'css', 'javascript', 'typescript', 'ex', 'heex' },
            -- },
            -- html = {},
            -- jsonls = {},
            lua_ls = {
                settings = {
                    Lua = {
                        runtime = {
                            version = 'LuaJIT',
                        },
                        diagnostics = {
                            globals = { 'hs', 'spoon', 'vim' },
                        },
                        workspace = {
                            checkThirdParty = false,
                            library = {
                                vim.env.VIMRUNTIME,
                            },
                        },
                        telemetry = { enable = false },
                    },
                },
            },
            -- pyright = {},
            -- svelte = {},
            -- tailwindcss = {
            --     init_options = {
            --         userLanguages = {
            --             elixir = 'html-eex',
            --             eelixir = 'html-eex',
            --             heex = 'html-eex',
            --         },
            --     },
            -- },
            -- terraformls = {},
            -- ts_ls = {},
        }

        -- Configure all other servers with basic setup
        for server_name, config in pairs(servers) do
            config.capabilities = vim.tbl_deep_extend('force', {}, capabilities, config.capabilities or {})
            -- Register the server configuration, then enable it
            vim.lsp.config(server_name, config)
            vim.lsp.enable(server_name)
        end
    end,
}
