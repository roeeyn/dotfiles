-- markdown + the fence languages that show up in Claude prompts, so
-- injected code blocks highlight.
local parsers = {
    'bash',
    'css',
    'diff',
    'dockerfile',
    'eex',
    'elixir',
    'erlang',
    'git_rebase',
    'gitcommit',
    'go',
    'hcl',
    'heex',
    'html',
    'javascript',
    'json',
    'lua',
    'markdown',
    'markdown_inline',
    'python',
    'regex',
    'sql',
    'terraform',
    'toml',
    'typescript',
    'yaml',
}

return {
    'nvim-treesitter/nvim-treesitter',
    -- The frozen `master` branch crashes on Neovim 0.12: its injection
    -- directives predate the 0.12 directive API (match is now a node list),
    -- so any prompt with a fenced code block errors. The `main` rewrite is
    -- the supported branch.
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    config = function()
        require('nvim-treesitter').install(parsers)
        -- No vim.treesitter.start() autocmd needed: Neovim 0.12 enables
        -- markdown treesitter highlighting by default, and injections
        -- highlight once the parsers above exist.
    end,
}
