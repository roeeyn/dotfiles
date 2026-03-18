if vim.loader then
    vim.loader.enable()
end

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

vim.opt.termguicolors = true
vim.opt.encoding = 'utf-8'
vim.opt.autoread = true
vim.opt.cursorline = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.scrolloff = 8
vim.opt.splitright = true
vim.opt.updatetime = 100
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }

vim.filetype.add {
    extension = {
        livemd = 'markdown',
    },
}

local slim_nvim = vim.api.nvim_create_augroup('slim-nvim', { clear = true })

vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufNewFile' }, {
    group = slim_nvim,
    pattern = '*',
    callback = function(args)
        local buffer = args.buf
        if vim.bo[buffer].buftype ~= '' or vim.bo[buffer].filetype ~= '' then
            return
        end

        local filename = vim.api.nvim_buf_get_name(buffer)
        local detected = vim.filetype.match {
            buf = buffer,
            filename = filename,
        }

        if detected then
            vim.bo[buffer].filetype = detected
            return
        end

        local basename = vim.fn.fnamemodify(filename, ':t')
        if basename == '' or not basename:find '%.+' then
            vim.bo[buffer].filetype = 'markdown'
        end
    end,
})

vim.api.nvim_create_autocmd('TextYankPost', {
    group = slim_nvim,
    callback = function()
        vim.highlight.on_yank { timeout = 200, on_visual = true }
    end,
})
