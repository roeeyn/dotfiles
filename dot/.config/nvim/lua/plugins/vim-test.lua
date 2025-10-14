return {
    'vim-test/vim-test',
    init = function()
        vim.g['test#strategy'] = 'neovim'
        vim.g['test#neovim#term_position'] = 'vert botright'
        vim.g['test#neovim#start_normal'] = 1 -- Start in normal mode so we can scroll

        -- Check if we're in the messaging_stats_service project
        local cwd = vim.fn.getcwd()
        if string.match(cwd, 'messaging_stats_service') then
            vim.g['test#elixir#exunit#executable'] = 'dockc run --rm -e MIX_ENV=test mss mix test'
        end
    end,
}
