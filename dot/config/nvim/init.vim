set path+=**

" Needed settings for font issues (Telescope)
set encoding=utf-8
" let g:airline_powerline_fonts = 1

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

"------------------------------------------------------------------------------"
"                                  Key mapping                                 "
"------------------------------------------------------------------------------"

let mapleader = " "
xnoremap <leader>y "+y<CR>
nnoremap <leader>ff <cmd>Telescope find_files<CR>
nnoremap <leader>fg <cmd>Telescope git_files<CR>
nnoremap <leader>f/ <cmd>Telescope live_grep<CR>
nnoremap <leader>fs <cmd>w<CR>
nnoremap <leader>fed <cmd>e ~/.config/nvim/init.vim<CR>
nnoremap <leader>fer <cmd>source ~/.config/nvim/init.vim<CR>
nnoremap <leader>;; <cmd>CommentToggle<CR>
nnoremap <leader>bb <cmd>Buffers<CR>
nnoremap <leader>qq <cmd>q<CR>
nnoremap <leader>cy yypk <cmd>CommentToggle<CR>j
nnoremap <leader>wh <C-W>h
nnoremap <leader>wl <C-W>l
nnoremap <leader>wj <C-W>j
nnoremap <leader>wk <C-W>k
nnoremap <leader>wp <cmd>vertical resize +10<CR>
nnoremap <leader>wo <cmd>vertical resize -10<CR>
nnoremap <leader>bd <cmd>bd<CR>
nnoremap <leader>wo <C-W>o
nnoremap <leader>el <cmd>lua vim.lsp.diagnostic.set_loclist()<CR>
nnoremap <leader>ec <cmd>lclose<CR>
nnoremap <leader>en <cmd>lnext<CR>
nnoremap <leader>ep <cmd>lprevious<CR>
nnoremap <leader>bp <cmd>bp<CR>
nnoremap <leader>bn <cmd>bn<CR>
nnoremap <leader>0 <cmd>FormatWrite<CR>
nnoremap <leader>dp <cmd>Pydocstring<CR>
nnoremap <leader>pt <cmd>NvimTreeToggle<CR>
nnoremap <leader>co <cmd>copen<CR>
nnoremap <leader>cc <cmd>cclose<CR>
nnoremap <leader>cn <cmd>cnext<CR>
nnoremap <leader>cp <cmd>cprevious<CR>
nnoremap <leader>is <cmd>%! isort --profile black %<CR>
nnoremap <leader>ir <cmd>:%! autoflake -i --remove-all-unused-imports --remove-unused-variables %<CR>
" WIP: For the deletion of the current element in the quickfix list
nnoremap <leader>cd <cmd>call setqflist(getqflist()[:get(getqflist({'idx': 1}), 'idx', 0)-2] + getqflist()[get(getqflist({'idx': 1}), 'idx', 0):])<CR>
nmap <leader>tu <Plug>BujoChecknormal
nmap <leader>ta <Plug>BujoAddnormal
nmap <leader>to <cmd>Todo<CR>
nmap <leader>tc <cmd>tabnew<CR>
nmap <leader>tn <cmd>tabnext<CR>
nmap <leader>tp <cmd>tabprevious<CR>
nmap <leader>tx <cmd>tabclose<CR>

" PLUGINS
call plug#begin('~/.vim/plugged')

" Vim Todo
Plug 'vuciv/vim-bujo'

" Pydoc
Plug 'heavenshell/vim-pydocstring', { 'do': 'make install' }

" Formatter
Plug 'mhartington/formatter.nvim'

" Fuzzy finder
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Nice comment frames
Plug 'cometsong/CommentFrame.vim'

" Colored parenthesis
Plug 'luochen1990/rainbow'

" Thin vertical lines at each indetation
Plug 'Yggdroot/indentLine'

" Wakatime
Plug 'wakatime/vim-wakatime'

" Emmet integration
Plug 'mattn/emmet-vim'

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

" Markdown preview
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install'  }

" isort Python
Plug 'fisadev/vim-isort'

" zoom
Plug 'dhruvasagar/vim-zoom'

" git gutter
Plug 'airblade/vim-gitgutter'

call plug#end()

let g:tokyonight_italic_functions = 1
let g:tokyonight_colors = {'dark5' : '#93d8d9', 'fg_gutter':'#555f8b'}
colorscheme tokyonight

let g:pydocstring_formatter = 'google'

let g:ycm_autoclose_preview_window_after_insertion = 1

let g:bujo#todo_file_path = $HOME . "/.cache/bujo"

let g:rainbow_active = 1 "set to 0 if you want to enable it later via :RainbowToggle
let g:rainbow_conf = {
  \'guifgs': ['darkturquoise','deeppink1', 'dodgerblue1', 'orange1', 'limegreen', 'firebrick1']
\}

lua vim.o.foldmethod = 'expr'
lua vim.o.foldexpr = 'nvim_treesitter#foldexpr()'
set nofoldenable

" Gitgutter to catches the changes faster
set updatetime=100

lua require('roeeyn')

set rtp+=~/tabnine-vim

