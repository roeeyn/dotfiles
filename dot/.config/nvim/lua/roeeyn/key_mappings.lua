----------------------------------------------------------------------
--                List of all the keymaps registered                --
----------------------------------------------------------------------
vim.g.mapleader = " "

local function map(mode, shortcut, command)
  vim.api.nvim_set_keymap(mode, shortcut, command, {
    noremap = true,
    -- TODO: Verify if this is ok
    -- silent = true,
  })
end

local function nmap(shortcut, command)
  map('n', shortcut, command)
end

local function vmap(shortcut, command)
  map('v', shortcut, command)
end

local function xmap(shortcut, command)
  map('x', shortcut, command)
end

-- Buffers
nmap('<leader>bb', '<cmd>Telescope buffers<cr>')
nmap('<leader>bd', '<cmd>Bdelete<cr>')
nmap('<leader>bx', '<cmd>bd<cr>')
nmap('<leader>bl', '<C-^>')
nmap('<leader>bn', '<cmd>bn<cr>')
nmap('<leader>bp', '<cmd>bp<cr>')
nmap('<leader>cy', 'yypk <cmd>CommentToggle<CR>j')
nmap('<leader>fs', '<cmd>w<cr>')
nmap('<leader>q1', '<cmd>q!<cr>')
nmap('<leader>qq', '<cmd>q<cr>')
nmap('<leader>wq', '<cmd>wq<cr>')

-- Coding
nmap('<leader>cR', '<cmd>lua vim.lsp.buf.rename()<cr>')
nmap('<leader>cs', '<cmd>lua vim.lsp.buf.signature_help()<cr>')
nmap('<leader>ct', '<cmd>lua vim.lsp.buf.hover()<cr>')
nmap('<leader>gD', '<cmd>lua vim.lsp.buf.declaration()<cr>')

-- Quickfix
nmap('<leader>cc', '<cmd>cclose<cr>')
nmap('<leader>cn', '<cmd>cnext<cr>')
nmap('<leader>co', '<cmd>copen<cr>')
nmap('<leader>cp', '<cmd>cprevious<cr>')

-- Documentation
nmap('<leader>do', '<cmd>DogeGenerate<cr>')

-- Debugger
nmap('<leader>dwh', '<cmd>lua require"dap.ui.widgets".hover()<cr>')
nmap('<leader>dws', '<cmd>lua local widgets=require"dap.ui.widgets";widgets.centered_float(widgets.scopes)<cr>')
nmap('<leader>db', '<cmd>lua require"dap".toggle_breakpoint()<cr>')
nmap('<leader>dso', '<cmd>lua require"dap".step_out()<cr>')
nmap('<leader>dsi', '<cmd>lua require"dap".step_into()<cr>')
nmap('<leader>dsv', '<cmd>lua require"dap".step_over()<cr>')
nmap('<leader>dst', '<cmd>lua require"dap".stop()<cr>')
nmap('<leader>dc', '<cmd>lua require"dap".continue()<cr>')
nmap('<leader>dsu', '<cmd>lua require"dap".up()<cr>')
nmap('<leader>dsd', '<cmd>lua require"dap".down()<cr>')
nmap('<leader>dr', '<cmd>lua require"dap".repl.open({}, "vsplit")<CR><C-w>l')
nmap('<leader>dut', '<cmd>lua require"dapui".toggle()<CR>')

-- Telescope
nmap('<leader>dtc', '<cmd>Telescope dap commands<cr>')
nmap('<leader>dtf', '<cmd>Telescope dap configurations<cr>')
nmap('<leader>dtb', '<cmd>Telescope dap list_breakpoints<cr>')
nmap('<leader>dtv', '<cmd>Telescope dap variables<cr>')
nmap('<leader>dtf', '<cmd>Telescope dap frames<cr>')
nmap('<leader>eO', '<cmd>lua require("telescope.builtin").diagnostics{}<cr>')
nmap('<leader>f/', '<cmd>Telescope current_buffer_fuzzy_find<cr>')
nmap('<leader>ff', '<cmd>Telescope find_files<cr>')
nmap('<leader>fg', '<cmd>Telescope git_files<cr>')
nmap('<leader>gd', '<cmd>Telescope lsp_definitions<cr>')
nmap('<leader>gi', '<cmd>Telescope lsp_implementations<cr>')
nmap('<leader>gr', '<cmd>Telescope lsp_references<cr>')
nmap('<leader>gt', '<cmd>Telescope git_status<cr>')
nmap('<leader>hf', '<cmd>Telescope help_tags<cr>')
nmap('<leader>kf', '<cmd>Telescope keymaps<cr>')
nmap('<leader>p/', '<cmd>Telescope live_grep<cr>')

-- Errors
nmap('<leader>ec', '<cmd>lclose<cr>')
nmap('<leader>el', '<cmd>lua vim.diagnostic.open_float()<cr>')
nmap('<leader>en', '<cmd>lnext<cr>')
nmap('<leader>eo', '<cmd>lua require("telescope.builtin").diagnostics{bufnr=0}<cr>')
nmap('<leader>ep', '<cmd>lprevious<cr>')

-- Neovim Config
nmap('<leader>fed', '<cmd>e ~/.dotfiles<cr>')
nmap('<leader>fer', '<cmd>lua package.loaded["plugins"] = nil<cr><cmd>luafile ~/.config/nvim/init.lua<cr>')

-- Fugitive
nmap('<leader>gp', '<cmd>G push<cr>')
nmap('<leader>gs', '<cmd>G<cr>4j')

-- Git Worktrees
nmap('<leader>gw', '<cmd>lua require("telescope").extensions.git_worktree.git_worktrees()<cr>')

-- Harpoon
nmap('<leader>ha', '<cmd>lua require("harpoon.mark").add_file()<cr>')
nmap('<leader>hh', '<cmd>lua require("roeeyn.plugins.harpoon").open_harpoon_telescope()<cr>')
nmap('<leader>hj', '<cmd>lua require("harpoon.ui").nav_file(1)<cr>')
nmap('<leader>hk', '<cmd>lua require("harpoon.ui").nav_file(2)<cr>')
nmap('<leader>hl', '<cmd>lua require("harpoon.ui").nav_file(3)<cr>')
nmap('<leader>hn', '<cmd>lua require("harpoon.ui").nav_next()<cr>')
nmap('<leader>h;', '<cmd>lua require("harpoon.ui").nav_file(4)<cr>')
nmap('<leader>ho', '<cmd>lua require("harpoon.ui").toggle_quick_menu()<cr>')
nmap('<leader>hp', '<cmd>lua require("harpoon.ui").nav_prev()<cr>')

-- Nvim Tree
nmap('<leader>pf', '<cmd>NvimTreeFindFile<cr>')
nmap('<leader>pt', '<cmd>NvimTreeToggle<cr>')

-- Printing * for python
nmap('<leader>pp', 'oprint("*"*20)<esc>yypkoprint()')

-- Tabs
nmap('<leader>tc', '<cmd>tabnew<cr>')
nmap('<leader>tn', '<cmd>tabnext<cr>')
nmap('<leader>tp', '<cmd>tabprevious<cr>')
nmap('<leader>tx', '<cmd>tabclose<cr>')

-- Testing
nmap('<leader>ua', '<cmd>TestSuite<cr>')
nmap('<leader>uf', '<cmd>TestFile<cr>')
nmap('<leader>ul', '<cmd>TestLast<cr>')
nmap('<leader>ut', '<cmd>TestNearest<cr>')

-- Windows
nmap('<leader>wh', '<C-W>h')
nmap('<leader>wj', '<C-W>j')
nmap('<leader>wk', '<C-W>k')
nmap('<leader>wl', '<C-W>l')
nmap('<leader>wO', '<C-W>o')
nmap('<leader>wo', '<cmd>vertical resize -10<cr>')
nmap('<leader>wp', '<cmd>vertical resize +10<cr>')

-- Moving lines up and down in visual mode
vmap('J', ":m '>+1<CR>gv=gv")
vmap('K', ":m '<-2<CR>gv=gv")

-- Yanking in visual mode to clipboard
xmap('<leader>y', '"+y<CR>')