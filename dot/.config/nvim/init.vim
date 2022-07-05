set path+=**

" Needed settings for font issues (Telescope)
set encoding=utf-8
" let g:airline_powerline_fonts = 1

" Column limit 120
set colorcolumn=120

" Cursor line
set cursorline

" Move to unerscore words
set iskeyword-=_

" Reads changes from external events
set autoread

" Needed for cool ayu colors
set termguicolors

" Is how many columns of whitespace a tab keypress or a backspace keypress is worth
set tabstop=2 softtabstop=2

" How many columns of whitespace a level of identation is worth
set shiftwidth=2

" Change sizes for python files
autocmd Filetype python setlocal ts=4 sw=4 sts=4

" Use spaces instead of \t
set expandtab

" The cursor is moved onto the window with 'scrolloff' screen lines around it
set scrolloff=8

" Set line numbers
set number

" Set relative line numbers
set relativenumber

" Enable the syntax highlighting
syntax enable

" Enable auto indenting in files
filetype indent on

" Enable auto indent (for unknown files)
set autoindent

" Enable smart indent (for unknown files)
set smartindent

" Set normal backspace behaviour
set backspace=indent,eol,start

" Ignore folders in search
set wildignore=*/node_modules/*,*/target/*,*/tmp/*,*/venv/*

" Highlight trailing spaces
highlight ExtraWhitespace ctermbg=red guibg=red
autocmd ColorScheme * highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/

" Adding comment string for elixir types
" when you enter a (new) buffer
augroup set-commentstring-ag
autocmd!
autocmd BufEnter *.ex,*.exs :lua vim.api.nvim_buf_set_option(0, "commentstring", "# %s")
" when you've changed the name of a file opened in a buffer, the file type may have changed
autocmd BufFilePost *.ex,*.exs :lua vim.api.nvim_buf_set_option(0, "commentstring", "# %s")
augroup END

" Show quotes in JSON
set conceallevel=0

"------------------------------------------------------------------------------"
"                                  Key mapping                                 "
"------------------------------------------------------------------------------"

let mapleader = " "
nnoremap <leader>0 <cmd>FormatWrite<CR>
nnoremap <leader>;; <cmd>CommentToggle<CR>
nnoremap <leader>bb <cmd>Telescope buffers<CR>
nnoremap <leader>bd <cmd>Bdelete<CR>
nnoremap <leader>bx <cmd>bd<CR>
nnoremap <leader>bl <C-^>
nnoremap <leader>bn <cmd>bn<CR>
nnoremap <leader>bp <cmd>bp<CR>
nnoremap <leader>cR <cmd>lua vim.lsp.buf.rename()<CR>
nnoremap <leader>cc <cmd>cclose<CR>
nnoremap <leader>cn <cmd>cnext<CR>
nnoremap <leader>co <cmd>copen<CR>
nnoremap <leader>cp <cmd>cprevious<CR>
nnoremap <leader>cs <cmd>lua vim.lsp.buf.signature_help()<CR>
nnoremap <leader>ct <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <leader>cy yypk <cmd>CommentToggle<CR>j

nnoremap <leader>do <cmd>DogeGenerate<CR>
nnoremap <leader>dwh <cmd>lua require'dap.ui.widgets'.hover()<CR>
nnoremap <leader>dws <cmd>lua local widgets=require'dap.ui.widgets';widgets.centered_float(widgets.scopes)<CR>
nnoremap <leader>db <cmd>lua require'dap'.toggle_breakpoint()<CR>
nnoremap <leader>dso <cmd>lua require'dap'.step_out()<CR>
nnoremap <leader>dsi <cmd>lua require'dap'.step_into()<CR>
nnoremap <leader>dsv <cmd>lua require'dap'.step_over()<CR>
nnoremap <leader>dst <cmd>lua require'dap'.stop()<CR>
nnoremap <leader>dc <cmd>lua require'dap'.continue()<CR>
nnoremap <leader>dsu <cmd>lua require'dap'.up()<CR>
nnoremap <leader>dsd <cmd>lua require'dap'.down()<CR>
" nnoremap <leader>drl <cmd>lua require'dap'.run_last()<CR>
nnoremap <leader>dr <cmd>lua require'dap'.repl.open({}, 'vsplit')<CR><C-w>l
nnoremap <leader>dtc <cmd>Telescope dap commands<CR>
nnoremap <leader>dtf <cmd>Telescope dap configurations<CR>
nnoremap <leader>dtb <cmd>Telescope dap list_breakpoints<CR>
nnoremap <leader>dtv <cmd>Telescope dap variables<CR>
nnoremap <leader>dtf <cmd>Telescope dap frames<CR>
nnoremap <leader>dut <cmd>lua require'dapui'.toggle()<CR>

nnoremap <leader>eO <cmd>lua require('telescope.builtin').diagnostics{}<CR>
nnoremap <leader>ec <cmd>lclose<CR>
nnoremap <leader>el <cmd>lua vim.diagnostic.open_float()<CR>
nnoremap <leader>en <cmd>lnext<CR>
nnoremap <leader>eo <cmd>lua require('telescope.builtin').diagnostics{bufnr=0}<CR>
nnoremap <leader>ep <cmd>lprevious<CR>
nnoremap <leader>f/ <cmd>Telescope current_buffer_fuzzy_find<CR>
nnoremap <leader>fed <cmd>e ~/.dotfiles<CR>
nnoremap <leader>fer <cmd>source ~/.config/nvim/init.vim<CR>
nnoremap <leader>ff <cmd>Telescope find_files<CR>
nnoremap <leader>fg <cmd>Telescope git_files<CR>
nnoremap <leader>fs <cmd>w<CR>
nnoremap <leader>gD <cmd>lua vim.lsp.buf.declaration()<CR>
nnoremap <leader>gd <cmd>Telescope lsp_definitions<CR>
nnoremap <leader>gi <cmd>Telescope lsp_implementations<CR>
nnoremap <leader>gp <cmd>G push<CR>
nnoremap <leader>gr <cmd>Telescope lsp_references<CR>
nnoremap <leader>gs <cmd>G<CR>4j
nnoremap <leader>gt <cmd>Telescope git_status<CR>
nnoremap <leader>gw <cmd>lua require('telescope').extensions.git_worktree.git_worktrees()<CR>
nnoremap <leader>ha <cmd>lua require("harpoon.mark").add_file()<CR>
nnoremap <leader>hf <cmd>Telescope help_tags<CR>
nnoremap <leader>hh <cmd>lua require('telescope').extensions.harpoon.marks({attach_mappings=function(_, map) map('i', '<c-d>', require('telescope.actions').preview_scrolling_down) return true end})<CR>
nnoremap <leader>hj <cmd>lua require("harpoon.ui").nav_file(1)<CR>
nnoremap <leader>hk <cmd>lua require("harpoon.ui").nav_file(2)<CR>
nnoremap <leader>hl <cmd>lua require("harpoon.ui").nav_file(3)<CR>
nnoremap <leader>hn <cmd>lua require("harpoon.ui").nav_next()<CR>
nnoremap <leader>h; <cmd>lua require("harpoon.ui").nav_file(4)<CR>
nnoremap <leader>ho <cmd>lua require("harpoon.ui").toggle_quick_menu()<CR>
nnoremap <leader>hp <cmd>lua require("harpoon.ui").nav_prev()<CR>
nnoremap <leader>kf <cmd>Telescope keymaps<CR>
nnoremap <leader>p/ <cmd>Telescope live_grep<CR>
nnoremap <leader>pf <cmd>NvimTreeFindFile<CR>
nnoremap <leader>pp oprint('*'*20)<esc>yypkoprint()
nnoremap <leader>pt <cmd>NvimTreeToggle<CR>
nnoremap <leader>q1 <cmd>q!<CR>
nnoremap <leader>qq <cmd>q<CR>
nnoremap <leader>ta <Plug>BujoAddnormal
nnoremap <leader>tc <cmd>tabnew<CR>
nnoremap <leader>tn <cmd>tabnext<CR>
nnoremap <leader>to <cmd>Todo<CR>
nnoremap <leader>tp <cmd>tabprevious<CR>
nnoremap <leader>tu <Plug>BujoChecknormal
nnoremap <leader>tx <cmd>tabclose<CR>
nnoremap <leader>ua <cmd>TestSuite<CR>
nnoremap <leader>uf <cmd>TestFile<CR>
nnoremap <leader>ul <cmd>TestLast<CR>
nnoremap <leader>ut <cmd>TestNearest<CR>
nnoremap <leader>wh <C-W>h
nnoremap <leader>wj <C-W>j
nnoremap <leader>wk <C-W>k
nnoremap <leader>wl <C-W>l
nnoremap <leader>wO <C-W>o
nnoremap <leader>wo <cmd>vertical resize -10<CR>
nnoremap <leader>wp <cmd>vertical resize +10<CR>
nnoremap <leader>wq <cmd>wq<CR>
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv
xnoremap <leader>y "+y<CR>

" PLUGINS
call plug#begin('~/.vim/plugged')

" Fuzzy finder
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Emmet
Plug 'mattn/emmet-vim'

" Folding improvement
Plug 'kevinhwang91/promise-async'
Plug 'kevinhwang91/nvim-ufo'

" Nice comment frames
Plug 'cometsong/CommentFrame.vim'

" Thin vertical lines at each indetation
Plug 'lukas-reineke/indent-blankline.nvim'

" Wakatime
Plug 'wakatime/vim-wakatime'

" Nice Syntax Highlighting
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}  " We recommend updating the parsers on update
Plug 'nvim-treesitter/playground'

" Nvim lsp configurations
Plug 'neovim/nvim-lspconfig'

" File Icons
Plug 'kyazdani42/nvim-web-devicons'
Plug 'kyazdani42/nvim-tree.lua'

" Telescope Dependencies
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzy-native.nvim'

" Git integration
Plug 'tpope/vim-fugitive'
Plug 'stsewd/fzf-checkout.vim'

" Nice bottom line
Plug 'hoob3rt/lualine.nvim'

" Color scheme
Plug 'folke/tokyonight.nvim'

" Comment
Plug 'terrortylor/nvim-comment'

" git gutter
Plug 'airblade/vim-gitgutter'

" Buffer delete
Plug 'famiu/bufdelete.nvim'

" GitHub Copilot
Plug 'github/copilot.vim'

" Harpoon
Plug 'ThePrimeagen/harpoon'

" Git Worktrees
Plug 'ThePrimeagen/git-worktree.nvim'

" Documentation Generator
Plug 'kkoomen/vim-doge', { 'do': { -> doge#install() } }

" Unit testing
Plug 'vim-test/vim-test'

" Flutter
Plug 'dart-lang/dart-vim-plugin'
Plug 'thosakwe/vim-flutter'
Plug 'natebosch/vim-lsc'
Plug 'natebosch/vim-lsc-dart'

" Debugger
Plug 'mfussenegger/nvim-dap'
Plug 'mfussenegger/nvim-dap-python'
Plug 'nvim-telescope/telescope-dap.nvim'
Plug 'theHamsta/nvim-dap-virtual-text'
Plug 'rcarriga/nvim-dap-ui'

call plug#end()

let g:doge_doc_standard_python = 'google'
let g:doge_comment_jump_modes = ['n', 's']

let test#strategy = "neovim"
let test#neovim#term_position = "vert botright"

let g:tokyonight_italic_functions = 1
let g:tokyonight_colors = {'dark5' : '#93d8d9', 'fg_gutter':'#555f8b'}
colorscheme tokyonight

" Gitgutter to catches the changes faster
set updatetime=100

lua require('roeeyn')

