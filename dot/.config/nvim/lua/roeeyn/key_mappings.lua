----------------------------------------------------------------------
--                List of all the keymaps registered                --
----------------------------------------------------------------------
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

local function map(mode, shortcut, command)
  vim.api.nvim_set_keymap(mode, shortcut, command, {
    noremap = true,
    -- TODO: Verify if this is ok
    -- silent = true,
  })
end

local function vmap(shortcut, command)
  map('v', shortcut, command)
end

local function xmap(shortcut, command)
  map('x', shortcut, command)
end

local function tmap(shortcut, command)
  map('t', shortcut, command)
end

-- Terminal
tmap('<esc>', '<C-\\><C-n>')

-- Moving lines up and down in visual mode
vmap('J', ":m '>+1<CR>gv=gv")
vmap('K', ":m '<-2<CR>gv=gv")

-- Yanking in visual mode to clipboard
xmap('<leader>y', '"+y<CR>')
