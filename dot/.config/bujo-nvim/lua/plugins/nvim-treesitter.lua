-- markdown + the fence languages actually used in the notes vault, so
-- injected code blocks highlight.
local parsers = {
    'bash',
    'elixir',
    'groovy',
    'hcl',
    'json',
    'markdown',
    'markdown_inline',
    'mermaid',
    'python',
    'sql',
    'yaml',
}

return {
    'nvim-treesitter/nvim-treesitter',
    -- The frozen `master` branch crashes on Neovim 0.12: its injection
    -- directives predate the 0.12 directive API (match is now a node list),
    -- so any note with a fenced code block errors. The `main` rewrite is
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
