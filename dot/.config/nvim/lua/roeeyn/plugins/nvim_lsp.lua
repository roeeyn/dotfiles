-- LSP Configuration
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
  -- TODO: TJ told me to do this and I should do it because he is Telescopic
  -- "Big Tech" "Cash Money" Johnson
  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
end

local folding_capabilities = vim.lsp.protocol.make_client_capabilities()
folding_capabilities.textDocument.foldingRange = {
  dynamicRegistration = false,
  lineFoldingOnly = true,
}

local capabilities = require('cmp_nvim_lsp').default_capabilities(folding_capabilities)

local servers = {
  ansiblels = {},
  dockerls = {},
  bashls = {},
  -- gopls={},
  tsserver = {},
  pyright = {
    python = {
      venv_path = '~/.pyenv/versions',
    },
  },
  rust_analyzer = {},
  html = {},
  svelte = {},
  jsonls = {},
  sumneko_lua = {
    Lua = {
      diagnostics = {
        globals = { 'hs', 'spoon', 'vim' },
      },
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
}

-- Setup mason so it can manage external tooling
require('mason').setup()

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
}

mason_lspconfig.setup_handlers {
  function(server_name)
    require('lspconfig')[server_name].setup {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = servers[server_name],
    }
  end,
}
