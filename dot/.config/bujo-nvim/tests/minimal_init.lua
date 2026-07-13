-- Minimal init for plenary/busted test runs: put the app config (for
-- lua/bujo/) and the lazy-installed plenary on the runtime path, nothing else.
local app_root = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':h:h')
vim.opt.rtp:prepend(app_root)
vim.opt.rtp:prepend(vim.fn.stdpath 'data' .. '/lazy/plenary.nvim')
