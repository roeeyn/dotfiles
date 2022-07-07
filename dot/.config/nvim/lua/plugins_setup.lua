-- TODO: Improve the indent line -> https://github.com/lukas-reineke/indent-blankline.nvim
require("indent_blankline").setup {
    -- for example, context is off by default, use this to turn it on
    show_current_context = true,
    show_current_context_start = true,
}

-- Theme configuration
vim.cmd[[colorscheme tokyonight]]
vim.g.tokyonight_italic_functions = 1 -- Disable italic functions
vim.g.tokyonight_colors = {dark5 = '#93d8d9', fg_gutter='#555f8b'}


-- Treesitter configuration
require('nvim-treesitter.configs').setup {
    highlight = {enable = true},
    -- indent = {enable = true}
}

-- Lualine
require('lualine').setup {options = {theme = 'tokyonight'}}


-- NvimTree
require('nvim-tree').setup {
  -- update the focused file on `BufEnter`, un-collapses the folders recursively until it finds the file
  update_focused_file = {
    -- enables the feature
    enable      = true,
    -- update the root directory of the tree to the one of the folder containing the file if the file is not under the current root directory
    -- only relevant when `update_focused_file.enable` is true
    update_cwd  = false,
    -- list of buffer names / filetypes that will not update the cwd if the file isn't found under the current root directory
    -- only relevant when `update_focused_file.update_cwd` is true and `update_focused_file.enable` is true
    ignore_list = {}
  },
}

-- Nvim Test
vim.g['test#strategy'] = "neovim"
vim.g['test#neovim#term_position'] = "vert botright"
vim.g['test#neovim#start_normal'] = 1 -- Start in normal mode so we can scroll

-- Nvim Comment
require('nvim_comment').setup({
  line_mapping = "<leader>;;",
  operator_mapping = "<leader>;;",
})

vim.g.doge_doc_standard_python = 'google'
vim.g.doge_comment_jump_modes = {'n', 's'}

-- Telescope
require("telescope").setup {
    pickers = {
      find_files = {
        hidden = true
      }
    },
    defaults = {
        mappings = {
            n = {
              ["<C-q>"] = require("telescope.actions").smart_send_to_qflist,
              ["<C-x>"] = require("telescope.actions").delete_buffer,
            },
            i = {
              ["<C-q>"] = require("telescope.actions").smart_send_to_qflist,
              ["<C-x>"] = require("telescope.actions").delete_buffer,
            }
        }
    }
}

require("telescope").load_extension("harpoon")
-- require("telescope").load_extension("dap")

--                             Nvim UFO (Folding)
-- tell the sever the capability of foldingRange
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true
}

vim.wo.foldcolumn = '1'
vim.wo.foldlevel = 99 -- feel free to decrease the value
vim.wo.foldenable = false

require('ufo').setup()
--

-- LSP Configuration
local function on_attach()
    -- TODO: TJ told me to do this and I should do it because he is Telescopic
    -- "Big Tech" "Cash Money" Johnson
end

require'lspconfig'.ansiblels.setup{on_attach=on_attach}
require'lspconfig'.dockerls.setup{on_attach=on_attach}
require'lspconfig'.elixirls.setup{
    -- Unix (Install from here -> https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#elixirls)
    on_attach = on_attach,
    cmd = { "/Users/roeeyn/.local/bin/elixir-ls/language_server.sh" };
}
require'lspconfig'.bashls.setup{on_attach=on_attach}
require'lspconfig'.gopls.setup{on_attach=on_attach}
require('lspconfig').tsserver.setup {on_attach = on_attach}
require('lspconfig').pyright.setup {
    on_attach = on_attach,
    settings = {python = {venv_path = '~/.pyenv/versions'}}
}
require('lspconfig').rust_analyzer.setup {on_attach = on_attach}
require('lspconfig').html.setup {on_attach = on_attach}
require'lspconfig'.svelte.setup {on_attach = on_attach}
require('lspconfig').jsonls.setup {
    on_attach = on_attach,
    commands = {
        Format = {
            function()
                vim.lsp.buf.range_formatting({}, {0, 0}, {vim.fn.line("$"), 0})
            end
        }
    }
}
require'lspconfig'.sumneko_lua.setup {
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = {'vim'},
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = vim.api.nvim_get_runtime_file("", true),
      },
      -- Do not send telemetry data containing a randomized but unique identifier
      telemetry = {
        enable = false,
      },
    },
  },
}

print('plugins setup!')
