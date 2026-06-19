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

-- Indentation: spaces, 4-wide (mirrors slim-nvim)
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

-- Shift-Tab dedents in insert mode
vim.keymap.set('i', '<S-Tab>', '<C-d>', { desc = 'Dedent line' })

-- Yank to system clipboard in visual mode
vim.keymap.set('x', '<leader>y', '"+y', { desc = 'Yank to clipboard' })

-- Window navigation / splitting (mirrors slim-nvim and main nvim config)
vim.keymap.set('n', '<leader>wh', '<C-w>h', { desc = 'Move to left window' })
vim.keymap.set('n', '<leader>wj', '<C-w>j', { desc = 'Move to bottom window' })
vim.keymap.set('n', '<leader>wk', '<C-w>k', { desc = 'Move to above window' })
vim.keymap.set('n', '<leader>wl', '<C-w>l', { desc = 'Move to right window' })
vim.keymap.set('n', '<leader>wv', '<C-w>v', { desc = 'Split window vertically' })
vim.keymap.set('n', '<leader>ws', '<C-w>s', { desc = 'Split window horizontally' })
vim.keymap.set('n', '<leader>w0', '<C-w>=', { desc = 'Resize windows equally' })
vim.keymap.set('n', '<leader>wc', '<cmd>close<cr>', { desc = 'Close the current window' })

-- Treat _ as a word boundary for w/e/b motions
vim.opt.iskeyword = vim.opt.iskeyword - '_'

local pg_nvim = vim.api.nvim_create_augroup('pg-nvim', { clear = true })

-- psql's \e writes the current query buffer to $TMPDIR/psql.edit.<pid>.sql,
-- opens this editor on it, then re-parses and EXECUTES whatever we save. So we:
--   BufReadPost  → append a "scissors" block of recent queries (for recall)
--   BufWritePre  → strip the scissors + everything below (so psql only runs the
--                  actual query, never the recalled history)
--
-- The scissors line is matched on MARKER, the box-drawing-dash + `8<` fragment.
-- Those `─` are U+2500 — never typed in real SQL — so the match is collision-
-- proof (even `WHERE n > 8`) without needing an ugly sentinel suffix on the line.
local SCISSORS_LINE = '-- ───────────────── 8< ─────────────────'
local SCISSORS_MARKER = '─ 8< ─'

local function is_psql_edit_buffer(buffer)
    local basename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buffer), ':t')
    return basename:match '^psql%.edit%.' ~= nil
end

vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufNewFile' }, {
    group = pg_nvim,
    -- `psql.edit.*` already matches `psql.edit.<pid>.sql`; a second `*.sql`
    -- pattern would make the event fire the callback twice (double injection).
    pattern = 'psql.edit.*',
    callback = function(args)
        if not is_psql_edit_buffer(args.buf) then
            return
        end

        local queries = vim.fn.systemlist 'pg-recent-queries'
        if vim.v.shell_error ~= 0 or #queries == 0 then
            return
        end

        local scissors = {
            '',
            SCISSORS_LINE,
            '-- Recent queries (newest first). This block is removed on save.',
            '',
        }
        vim.list_extend(scissors, queries)

        -- Append below any existing draft so a pre-filled buffer is preserved.
        local last = vim.api.nvim_buf_line_count(args.buf)
        vim.api.nvim_buf_set_lines(args.buf, last, last, false, scissors)
        vim.api.nvim_win_set_cursor(0, { 1, 0 })
    end,
})

vim.api.nvim_create_autocmd('BufWritePre', {
    group = pg_nvim,
    pattern = 'psql.edit.*',
    callback = function(args)
        if not is_psql_edit_buffer(args.buf) then
            return
        end

        local lines = vim.api.nvim_buf_get_lines(args.buf, 0, -1, false)
        for i, line in ipairs(lines) do
            if line:find(SCISSORS_MARKER, 1, true) then
                -- Keep everything above the scissors, drop trailing blank lines.
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

-- Wire schema-aware completion (vim-dadbod-completion) to the active service.
-- The `db` wrapper exports PG_NVIM_SERVICE and psql passes PGPASSWORD down to us,
-- so an empty-host service URL lets vim-dadbod introspect via ~/.pg_service.conf
-- with zero duplicated credentials. No connection opens until completion is
-- actually triggered, and the schema is cached for the session.
vim.api.nvim_create_autocmd('FileType', {
    group = pg_nvim,
    pattern = 'sql',
    callback = function(args)
        -- Format with pg_format on `gq` (incl. visual `gq`): Vim pipes the
        -- motion/selection through pgFormatter's stdin and swaps in the result.
        -- It's an in-buffer filter — no write, so psql never runs, and selecting
        -- just your query leaves the recalled-history block untouched.
        vim.bo[args.buf].formatprg = 'pg_format -'

        local service = vim.env.PG_NVIM_SERVICE
        if service and service ~= '' then
            vim.b[args.buf].db = 'postgresql:///?service=' .. service
        end
    end,
})

-- Distinct flash color when a yank lands in the system clipboard (`+`).
vim.api.nvim_set_hl(0, 'YankClipboard', { bg = '#83c092', fg = '#2d353b', bold = true }) -- everforest aqua

vim.api.nvim_create_autocmd('TextYankPost', {
    group = pg_nvim,
    callback = function()
        local higroup = vim.v.event.regname == '+' and 'YankClipboard' or 'IncSearch'
        vim.highlight.on_yank { timeout = 200, on_visual = true, higroup = higroup }
    end,
})
