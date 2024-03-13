-- LSP Configuration
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
    -- TODO: TJ told me to do this and I should do it because he is Telescopic
    -- "Big Tech" "Cash Money" Johnson

    -- TODO(@roeeyn): Verify this is working with conform plugin
    -- Create a command `:Format` local to the LSP buffer
    -- vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    --     vim.lsp.buf.format()
    -- end, { desc = 'Format current buffer with LSP' })
end

local servers = {
    ansiblels = {},
    dockerls = {},
    bashls = {},
    gopls = {},
    graphql = {},
    elixirls = {},
    emmet_ls = {},
    tsserver = {},
    pyright = {
        settings = {
            python = {
                venv_path = '~/.pyenv/versions',
            },
        },
    },
    rust_analyzer = {},
    html = {},
    svelte = {},
    jsonls = {},
    tailwindcss = {},
    lua_ls = {
        settings = {
            Lua = {
                diagnostics = {
                    globals = { 'hs', 'spoon', 'vim' },
                },
                workspace = { checkThirdParty = false },
                telemetry = { enable = false },
            },
        },
    },
}

require('mason').setup()
require('mason-lspconfig').setup {
    ensure_installed = vim.tbl_keys(servers),
}

local lspconfig = require 'lspconfig'

for server, config in pairs(servers) do
    -- TODO: maybe refactor to avoid creating a new closure per server
    -- if config.on_attach then
    --   local old_on_attach = config.on_attach
    --   config.on_attach = function(client, bufnr)
    --     old_on_attach(client, bufnr)
    --     do_on_attach_fns(client, bufnr)
    --   end
    -- else
    --   config.on_attach = function(client, bufnr)
    --     do_on_attach_fns(client, bufnr)
    --   end
    -- end

    -- config.capabilities = vim.tbl_deep_extend('keep', config.capabilities or {}, client_capabilities)
    lspconfig[server].setup(config)
end
