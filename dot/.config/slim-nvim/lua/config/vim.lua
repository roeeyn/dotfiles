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

-- Indentation: use spaces, 4-wide
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

-- Shift-Tab dedents in insert mode
vim.keymap.set('i', '<S-Tab>', '<C-d>', { desc = 'Dedent line' })

-- Yank to system clipboard in visual mode
vim.keymap.set('x', '<leader>y', '"+y', { desc = 'Yank to clipboard' })

-- Window navigation (mirrors main nvim config: which-key.lua)
vim.keymap.set('n', '<leader>wh', '<C-w>h', { desc = 'Move to left window' })
vim.keymap.set('n', '<leader>wj', '<C-w>j', { desc = 'Move to bottom window' })
vim.keymap.set('n', '<leader>wk', '<C-w>k', { desc = 'Move to above window' })
vim.keymap.set('n', '<leader>wl', '<C-w>l', { desc = 'Move to right window' })

-- Window splitting (mirrors main nvim config)
vim.keymap.set('n', '<leader>wv', '<C-w>v', { desc = 'Split window vertically' })
vim.keymap.set('n', '<leader>ws', '<C-w>s', { desc = 'Split window horizontally' })

-- Close current window — mirrors main nvim's <leader>wc.
-- In slim-nvim a single buffer is shown across multiple windows, so we close
-- the window (`:close`), not the buffer.
vim.keymap.set('n', '<leader>wc', '<cmd>close<cr>', { desc = 'Close the current window' })

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

        local scissors = {
            '',
            '# ─────────────────── >8 ───────────────────',
            '# Do not modify or remove the line above.',
            '# Everything below will NOT be sent as prompt.',
            '#',
            '# Recent conversation (newest first):',
            '',
        }
        vim.list_extend(scissors, result)

        -- Append scissors below existing content (preserves draft from prompt line)
        local last_line = vim.api.nvim_buf_line_count(args.buf)
        vim.api.nvim_buf_set_lines(args.buf, last_line, last_line, false, scissors)
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

-- Distinct flash color when the yank lands in the system clipboard (`+`).
vim.api.nvim_set_hl(0, 'YankClipboard', { bg = '#689d6a', fg = '#fbf1c7', bold = true }) -- gruvbox neutral aqua

vim.api.nvim_create_autocmd('TextYankPost', {
    group = slim_nvim,
    callback = function()
        local higroup = vim.v.event.regname == '+' and 'YankClipboard' or 'IncSearch'
        vim.highlight.on_yank { timeout = 200, on_visual = true, higroup = higroup }
    end,
})

-- Highlight Claude skills (e.g. /morning, /commit) — matches a single /word
-- token that is NOT part of a path (i.e. contains exactly one /)
vim.api.nvim_set_hl(0, 'ClaudeSkill', { fg = '#d3869b', bold = true }) -- gruvbox purple

vim.api.nvim_create_autocmd({ 'BufWinEnter', 'WinEnter' }, {
    group = slim_nvim,
    callback = function()
        -- Avoid duplicate matches in the same window
        if vim.w.claude_skill_match then
            return
        end
        -- Pattern: start-of-line or whitespace, then /word (letters, digits, _, -)
        -- The character class after / excludes /, so paths like /foo/bar won't match
        vim.fn.matchadd('ClaudeSkill', [[\v(^|\s)\zs\/[a-zA-Z][a-zA-Z0-9_-]*\ze(\s|$)]])
        vim.w.claude_skill_match = true
    end,
})
