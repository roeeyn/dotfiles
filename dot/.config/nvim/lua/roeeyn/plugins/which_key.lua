local wk = require 'which-key'

wk.register({
  -- nvim_comment.lua
  [';'] = { 'Toggle group comment' },
  b = {
    name = 'Buffers',
    D = { '<cmd>%bd|e#|bd#<cr>', 'Close other buffers' },
    b = { '<cmd>Telescope buffers<cr>', 'Telescope buffers' },
    d = { '<cmd>Bdelete<cr>', 'Soft remove buffer' },
    x = { '<cmd>bd<cr>', 'Hard remove buffer' },
    l = { '<C-^>', 'Last buffer' },
    n = { '<cmd>bn<cr>', 'Next Buffer' },
    p = { '<cmd>bp<cr>', 'Previous buffer' },
  },
  c = {
    name = 'Code',
    R = { '<cmd>lua vim.lsp.buf.rename()<cr>', '[LSP] Rename definition' },
    a = { '<cmd>lua vim.lsp.buf.code_action()<cr>', '[LSP] Diagn. Action' },
    c = { '<cmd>cclose<cr>', '[Quickfix] Close' },
    d = { '<cmd>lua vim.lsp.buf.declaration()<cr>', '[LSP] Go To Declaration' },
    f = { '[Comment] Frame one line' },
    g = { '<cmd>cc<cr>', '[Quickfix] Go to current element' },
    l = { '<cmd>Telescope quickfix<cr>', '[Quickfix] List quickfix elements' },
    m = { '[Comment] Frame multiple lines' },
    n = { '<cmd>cnext<cr>', '[Quickfix] Go to next element' },
    o = { '<cmd>copen<cr>', '[Quickfix] Open quickfix list' },
    p = { '<cmd>cprevious<cr>', '[Quickfix] Go to prev element' },
    s = { '<cmd>lua vim.lsp.buf.signature_help()<cr>', '[LSP] Signature help' },
    t = { '<cmd>lua vim.lsp.buf.hover()<cr>', '[LSP] Hover Info' },
    x = { '<cmd>lua vim.fn.setqflist({})<cr>', '[Quickfix] Clear quickfix' },
    y = { 'yypk <cmd>CommentToggle<CR>j', '[Misc] Duplicate and comment' },
  },
  d = {
    name = 'Debug/Diag.',
    b = { '<cmd>lua require"dap".toggle_breakpoint()<cr>', '[Debug] Toggle Breakpoint' },
    c = { '<cmd>lua require"dap".continue()<cr>', '[Debug] Start/Continue' },
    h = { "<cmd>lua require'dap.ui.widgets'.hover()<cr>", '[Debug] Hover' },
    n = { '<cmd>lua vim.diagnostic.goto_next()<cr>', '[Diag] Go Next' },
    o = { '<cmd>DogeGenerate<cr>', '[DoGe] Generate docs' },
    p = { '<cmd>lua vim.diagnostic.goto_prev()<cr>', '[Diag] Go Prev' },
    r = { '<cmd>lua require"dap".repl.open({}, "vsplit")<CR><C-w>l', '[Debug] Open REPL' },
    s = {
      name = 'Debugging',
      d = { '<cmd>lua require"dap".down()<cr>', 'Down' },
      i = { '<cmd>lua require"dap".step_into()<cr>', 'Step into' },
      o = { '<cmd>lua require"dap".step_out()<cr>', 'Step out' },
      t = { '<cmd>lua require"dap".stop()<cr>', 'Stop' },
      u = { '<cmd>lua require"dap".up()<cr>', 'Up' },
      v = { '<cmd>lua require"dap".step_over()<cr>', 'Step over' },
    },
    t = {
      name = 'Telescope DAP',
      b = { '<cmd>Telescope dap list_breakpoints<cr>', '[DAP] List breakpoints' },
      c = { '<cmd>Telescope dap commands<cr>', '[DAP] List commands' },
      f = { '<cmd>Telescope dap frames<cr>', '[DAP] List frames' },
      v = { '<cmd>Telescope dap variables<cr>', '[DAP] List variables' },
    },
    u = { "<cmd>lua require'dapui'.()<CR>", '[Debug] Toggle UI' },
  },
  e = {
    name = 'Errors',
    O = { '<cmd>lua require("telescope.builtin").diagnostics{}<cr>', 'Open diagnostics' },
    c = { '<cmd>lclose<cr>', 'Close location list' },
    l = { '<cmd>lua vim.diagnostic.open_float()<cr>', 'Open diagnostic float' },
    p = { '<cmd>lprevious<cr>', 'Prev location list item' },
    n = { '<cmd>lnext<cr>', 'Next location list item' },
    o = { '<cmd>lua require("telescope.builtin").diagnostics{bufnr=0}<cr>', 'Open current buffer diagnostics' },
  },
  f = {
    name = 'File/Find', -- optional group name
    f = { '<cmd>Telescope find_files<cr>', '[Telescope] Find file' },
    h = { '<cmd>Telescope help_tags<cr>', '[Telescope] Find help tags' },
    k = { '<cmd>Telescope keymaps<cr>', '[Telescope] Find keymaps' },
    -- s = { 'Save current buffer' }, -- just a label. don't create any mapping
    r = { '<cmd>Telescope resume<cr>', '[Telescope] Resume' },
    s = { '<cmd>w<cr>', '[File] Save current buffer' },
    S = { '<cmd>wa<cr>', '[File] Save all buffers' },
    t = { '<cmd>Telescope builtin<cr>', '[Telescope] builtin' },
    -- ['/'] = 'Fuzzy search in current buffer', -- same as above
    ['/'] = { '<cmd>Telescope current_buffer_fuzzy_find<cr>', '[Telescope] Fuzzy search in buffer' },
  },
  g = {
    name = 'Git/GitHub/GoTo',
    T = { '<cmd>Telescope lsp_type_definitions<cr>', '[GoTo] LSP type definitions' },
    d = { '<cmd>Telescope lsp_definitions<cr>', '[GoTo] LSP definitions' },
    i = { '<cmd>Telescope lsp_implementations<cr>', '[GoTo] LSP implementations' },
    r = { '<cmd>Telescope lsp_references<cr>', '[GoTo] LSP references' },
    D = { '<cmd>GitGutterDiffOrig<cr>', '[Git] Diff Hunk' },
    P = { '<cmd>G push<cr>', '[Git] push' },
    b = { '<cmd>G blame<cr>', '[Git] blame' },
    c = { '<cmd>G commit<cr>', '[Git] commit' },
    m = { '[Git] See Git Message' },
    n = { '<cmd>GitGutterNextHunk<cr>', '[Git] Next Hunk' },
    o = { '<cmd>GitGutterPreviewHunk<cr>', '[Git] Preview Hunk' },
    p = { '<cmd>GitGutterPrevHunk<cr>', '[Git] Prev Hunk' },
    s = { '<cmd>G<cr>4j', '[Git] status' },
    t = { '<cmd>Telescope git_status<cr>', '[Git] changed files' },
    x = { '<cmd>GitGutterUndoHunk<cr>', '[Git] Undo Hunk' },
    y = { '[GitHub] Create GitHub Permalink' },
    C = { '<cmd>vsplit | term gh pr create<cr>', '[GitHub] Create Pull Request' },
  },
  h = {
    name = 'Harpoon',
    a = { '<cmd>lua require("harpoon.mark").add_file()<cr><cmd>lua print("Mark added to harpoon")<cr>', 'Add file' },
    h = { '<cmd>lua require("roeeyn.plugins.harpoon").open_harpoon_telescope()<cr>', 'Open Telescope marks' },
    j = { '<cmd>lua require("harpoon.ui").nav_file(1)<cr>', 'Go to mark 1' },
    k = { '<cmd>lua require("harpoon.ui").nav_file(2)<cr>', 'Go to mark 2' },
    l = { '<cmd>lua require("harpoon.ui").nav_file(3)<cr>', 'Go to mark 3' },
    [';'] = { '<cmd>lua require("harpoon.ui").nav_file(4)<cr>', 'Go to mark 4' },
    n = { '<cmd>lua require("harpoon.ui").nav_next()<cr>', 'Go to next mark' },
    p = { '<cmd>lua require("harpoon.ui").nav_prev()<cr>', 'Go to prev mark' },
    o = { '<cmd>lua require("harpoon.ui").toggle_quick_menu()<cr>', 'Toggle quick menu' },
    x = { '<cmd>lua require("harpoon.mark").clear_all()<cr><cmd>lua print("Removed harpoons")<cr>', 'Clear all marks' },
  },
  l = {
    name = 'Line',
    [';'] = { 'Toggle line comment' },
  },
  q = {
    name = 'Quit',
    q = { '<cmd>q<cr>', 'Soft quit' },
    ['1'] = { '<cmd>q!<cr>', 'Force quit' },
  },
  p = {
    name = 'Project',
    t = { '<cmd>Telescope file_browser<cr>', 'File browser' },
    ['/'] = { '<cmd>Telescope live_grep<cr>', 'Live grep in whole project' },
  },
  r = {
    name = 'Run',
    p = { '<cmd>vsplit | term .git/hooks/pre-commit<cr>', '[Run] pre-commit' },
  },
  t = {
    name = 'Tab',
    ['1'] = { '<cmd>tabnext 1<cr>', 'Go to tab 1' },
    ['2'] = { '<cmd>tabnext 2<cr>', 'Go to tab 2' },
    ['3'] = { '<cmd>tabnext 3<cr>', 'Go to tab 3' },
    ['4'] = { '<cmd>tabnext 4<cr>', 'Go to tab 4' },
    ['5'] = { '<cmd>tabnext 5<cr>', 'Go to tab 5' },
    c = { '<cmd>tabnew<cr>', 'Create new tab' },
    n = { '<cmd>tabnext<cr>', 'Go to next tab' },
    p = { '<cmd>tabprevious<cr>', 'Go to prev tab' },
    o = { '<cmd>tabo<cr>', 'Close other tabs' },
    l = { '<cmd>tabl<cr>', 'Go to last tab' },
    x = { '<cmd>tabclose<cr>', 'Close current tab' },
  },
  u = {
    name = 'Testing',
    a = { '<cmd>TestSuite<cr>', 'Test all suite' },
    f = { '<cmd>TestFile<cr>', 'Test file' },
    l = { '<cmd>TestLast<cr>', 'Test last' },
    t = { '<cmd>TestNearest<cr>', 'Test nearest' },
  },
  w = {
    name = 'Window',
    h = { '<C-W>h', 'Move to left window' },
    j = { '<C-W>j', 'Move to bottom window' },
    k = { '<C-W>k', 'Move to above window' },
    l = { '<C-W>l', 'Move to right window' },
    O = { '<C-W>o', 'Close other windows' },
    o = { '<cmd>vertical resize -10<cr>', 'Resize window to the left' },
    p = { '<cmd>vertical resize +10<cr>', 'Resize window to the right' },
    q = { '<cmd>wq<cr>', 'Save and quit window' },
    t = { '<cmd>tabe %<cr>', 'Edit current buffer in new tab' },
  },
  y = {
    name = 'Yank',
    h = { "<cmd>lua require('telescope').extensions.neoclip.default()<cr>", 'Yank history' },
  },
}, { prefix = '<leader>' })
