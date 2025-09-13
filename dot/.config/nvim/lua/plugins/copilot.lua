return {
    {
        -- GitHub Copilot
        'zbirenbaum/copilot.lua',
        cmd = 'Copilot',
        event = 'InsertEnter',
        opts = {
            suggestion = { enabled = false },
            panel = { enabled = false },
        },
    },
    {
        -- Copilot inside the cmp window
        'zbirenbaum/copilot-cmp',
        dependencies = {
            'copilot.lua',
        },
        config = function()
            require('copilot_cmp').setup()
        end,
    },
}
