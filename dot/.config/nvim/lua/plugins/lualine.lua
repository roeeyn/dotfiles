return {
    'nvim-lualine/lualine.nvim',
    dependencies = {
        'nvim-tree/nvim-web-devicons',
    },
    opts = {
        options = {
            theme = 'tokyonight',
        },
        extensions = { 'quickfix', 'nvim-tree', 'trouble' },
        sections = {
            lualine_b = {
                'branch',
                'diff',
                "require('arrow.statusline').text_for_statusline_with_icons()",
                'diagnostics',
            },
            -- LSP status (no :Lsp* commands needed):
            --   * "⟳ indexing" shows while any server is building its index
            --     (vim.lsp.status() is non-empty). It clears when the build is
            --     done -> that blank state IS your "ready to jump" signal.
            --   * the server list shows which clients are attached to this
            --     buffer ("expert tailwindcss" on Elixir files, "none" if not).
            -- Re-includes the default lualine_x items so they aren't dropped.
            lualine_x = {
                {
                    function()
                        return vim.lsp.status() ~= '' and '⟳ indexing' or ''
                    end,
                    color = { fg = '#e0af68' },
                },
                {
                    function()
                        local names = vim.tbl_map(function(c)
                            return c.name
                        end, vim.lsp.get_clients { bufnr = 0 })
                        return #names > 0 and (' ' .. table.concat(names, ' ')) or ' none'
                    end,
                },
                'encoding',
                'fileformat',
                'filetype',
            },
        },
    },
}
