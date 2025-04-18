require('treesitter-context').setup {
    enable = true,
    max_lines = 10, -- no max lines if <= 0
    zindex = 50,
    patterns = {
        default = {
            'class',
            'function',
            'method',
            'for',
            'while',
            'if',
            'switch',
            'case',
            'else',
        },
        python = {
            'with',
            'try',
            'except',
            'elif',
        },
    },
    exact_patterns = {
        python = true,
    },
}

require('nvim-treesitter.configs').setup {
    -- Add languages to be installed here that you want installed for treesitter
    ensure_installed = {
        'comment',
        'dockerfile',
        'eex',
        'elixir',
        'git_config',
        'git_rebase',
        'gitattributes',
        'gitcommit',
        'gitignore',
        'go',
        'godot_resource',
        'gomod',
        'gosum',
        'gowork',
        'graphql',
        'heex',
        'hjson',
        'html',
        'javascript',
        'json',
        'json5',
        'jsonc',
        'jq',
        'lua',
        'markdown',
        'markdown_inline',
        'make',
        'mermaid',
        'passwd',
        'python',
        'rust',
        'sql',
        'todotxt',
        'typescript',
        'yaml',
        'vim',
        'vimdoc',
    },
    auto_install = true,
    highlight = { enable = true },
    indent = { enable = true },
    autotag = {
        enable = true,
    },
    textsubjects = {
        enable = true,
        prev_selection = ',', -- (Optional) keymap to select the previous selection
        keymaps = {
            ['.'] = 'textsubjects-smart',
            [';'] = 'textsubjects-container-outer',
            ['i;'] = 'textsubjects-container-inner',
        },
    },
    playground = {
        enable = true,
    },
    matchup = {
        enable = true,
        disable = {},
    },
}
