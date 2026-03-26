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

-- Move to underscore words (treat _ as word boundary for w/e/b motions)
vim.opt.iskeyword = vim.opt.iskeyword - '_'

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

-- Claude Code <C-g> prompt context (git commit --verbose style):
-- BufReadPost: populate buffer with scissors line + recent responses
-- BufWritePre: strip everything from scissors down so only the prompt is sent
vim.api.nvim_create_autocmd('BufReadPost', {
    group = slim_nvim,
    pattern = '*claude-prompt-*.md',
    callback = function(args)
        local result = vim.fn.systemlist 'claude-last-response'
        if vim.v.shell_error ~= 0 or #result == 0 then
            return
        end

        local content = {
            '',
            '# ─────────────────── >8 ───────────────────',
            '# Do not modify or remove the line above.',
            '# Everything below will NOT be sent as prompt.',
            '#',
            '# Recent conversation (newest first):',
            '',
        }
        vim.list_extend(content, result)

        vim.api.nvim_buf_set_lines(args.buf, 0, -1, false, content)
        vim.api.nvim_win_set_cursor(0, { 1, 0 })
    end,
})

vim.api.nvim_create_autocmd('BufWritePre', {
    group = slim_nvim,
    pattern = '*claude-prompt-*.md',
    callback = function(args)
        local lines = vim.api.nvim_buf_get_lines(args.buf, 0, -1, false)
        for i, line in ipairs(lines) do
            if line:find '>8' then
                -- Trim scissors + everything below, then strip trailing blanks
                local keep = {}
                for j = 1, i - 1 do
                    keep[j] = lines[j]
                end
                while #keep > 0 and keep[#keep] == '' do
                    keep[#keep] = nil
                end
                vim.api.nvim_buf_set_lines(args.buf, 0, -1, false, keep)
                return
            end
        end
    end,
})

vim.api.nvim_create_autocmd('TextYankPost', {
    group = slim_nvim,
    callback = function()
        vim.highlight.on_yank { timeout = 200, on_visual = true }
    end,
})
