require'formatter'.setup {
    logging = true,
    filetype = {
        json = {
            function()
                return {
                    exe = "prettier",
                    args = {
                        "--stdin-filepath ", vim.api.nvim_buf_get_name(0), ""
                    },
                    stdin = true
                }
            end
        },
        typescript = {
            function()
                return {
                    exe = "prettier",
                    args = {
                        "--stdin-filepath ", vim.api.nvim_buf_get_name(0), ""
                    },
                    stdin = true
                }
            end
        },
        typescriptreact = {
            function()
                return {
                    exe = "prettier",
                    args = {
                        "--stdin-filepath ", vim.api.nvim_buf_get_name(0), ""
                    },
                    stdin = true
                }
            end
        },
        proto = {
            function()
                return {
                    exe = "clang-format",
                    args = {"", vim.api.nvim_buf_get_name(0), ""},
                    stdin = false
                }
            end
        },
        rust = {
            function()
                return {
                    exe = "rustfmt",
                    args = {"", vim.api.nvim_buf_get_name(0), ""},
                    stdin = false
                }
            end
        },
        python = {
            function()
                return {
                    exe = "black",
                    args = {"", vim.api.nvim_buf_get_name(0), ""},
                    stdin = false
                }
            end
        }
    }
}