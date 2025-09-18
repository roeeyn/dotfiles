return {
    'kdheepak/lazygit.nvim',
    lazy = true,
    cmd = {
        'LazyGit',
        'LazyGitConfig',
        'LazyGitCurrentFile',
        'LazyGitFilter',
        'LazyGitFilterCurrentFile',
    },
    config = function()
        vim.g.lazygit_use_custom_config_file_path = 1
        vim.g.lazygit_config_file_path = vim.fn.expand '~/.config/lazygit/config.yml'
    end,
}
