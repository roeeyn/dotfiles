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

-- Prose: soft-wrap on word boundaries, keep wrapped lines aligned with
-- their list indentation.
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true

-- render-markdown drives concealment; level 2 hides raw markup under its
-- rendered glyphs. concealcursor stays empty so the current line shows the
-- raw text for editing.
vim.opt.conceallevel = 2

-- No swap noise for a notes app; undo history persists instead.
vim.opt.swapfile = false
vim.opt.undofile = true

-- Indentation: use spaces, 4-wide (nested task blocks rely on it)
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- Shift-Tab dedents in insert mode
vim.keymap.set('i', '<S-Tab>', '<C-d>', { desc = 'Dedent line' })

-- Yank to system clipboard in visual mode
vim.keymap.set('x', '<leader>y', '"+y', { desc = 'Yank to clipboard' })

-- File save (mirrors main nvim config)
vim.keymap.set('n', '<leader>fs', '<cmd>w<cr>', { desc = '[File] Save current buffer' })
vim.keymap.set('n', '<leader>fS', '<cmd>wa<cr>', { desc = '[File] Save all buffers' })

-- Buffers (mirrors main nvim config; no Bdelete here, plain :bd suffices)
vim.keymap.set('n', '<leader>bb', '<cmd>Telescope buffers<cr>', { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>bn', '<cmd>bn<cr>', { desc = 'Next buffer' })
vim.keymap.set('n', '<leader>bp', '<cmd>bp<cr>', { desc = 'Previous buffer' })
vim.keymap.set('n', '<leader>bl', '<C-^>', { desc = 'Last buffer' })
vim.keymap.set('n', '<leader>bd', '<cmd>bd<cr>', { desc = 'Remove buffer' })
vim.keymap.set('n', '<leader>bx', '<cmd>bd!<cr>', { desc = 'Remove buffer (discard changes)' })
vim.keymap.set('n', '<leader>bD', '<cmd>%bd|e#|bd#<cr>', { desc = 'Close other buffers' })

-- Window navigation/splitting (mirrors slim-nvim / main nvim config)
vim.keymap.set('n', '<leader>wh', '<C-w>h', { desc = 'Move to left window' })
vim.keymap.set('n', '<leader>wj', '<C-w>j', { desc = 'Move to bottom window' })
vim.keymap.set('n', '<leader>wk', '<C-w>k', { desc = 'Move to above window' })
vim.keymap.set('n', '<leader>wl', '<C-w>l', { desc = 'Move to right window' })
vim.keymap.set('n', '<leader>wv', '<C-w>v', { desc = 'Split window vertically' })
vim.keymap.set('n', '<leader>ws', '<C-w>s', { desc = 'Split window horizontally' })
vim.keymap.set('n', '<leader>w0', '<C-w>=', { desc = 'Resize windows equally' })
vim.keymap.set('n', '<leader>wc', '<cmd>close<cr>', { desc = 'Close the current window' })

local bujo_nvim = vim.api.nvim_create_augroup('bujo-nvim', { clear = true })

vim.api.nvim_create_autocmd('TextYankPost', {
    group = bujo_nvim,
    callback = function()
        vim.highlight.on_yank { timeout = 200, on_visual = true }
    end,
})
