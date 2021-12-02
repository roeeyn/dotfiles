require'formatter'.setup {
    logging = true,
    filetype = {
        xjavascriptreact = {
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
        xmarkdown = {
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
        xhtml = {
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
        xsvelte = {
            function()
                return {
                    exe = "prettier",
                    args = {
                        "--stdin-filepath ", vim.api.nvim_buf_get_name(0), " --plugin prettier-plugin-svelte"
                    },
                    stdin = true
                }
            end
        },
        xjavascript = {
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
        xjson = {
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
        xtypescript = {
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
        xtypescriptreact = {
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

