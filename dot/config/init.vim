" Needed settings for font issues (Telescope)
set encoding=utf-8
" let g:airline_powerline_fonts = 1

" Reads changes from external events
set autoread

" Needed for cool ayu colors
set termguicolors

" Is how many columns of whitespace a tab keypress or a backspace keypress is worth
set tabstop=2 softtabstop=2

" How many columns of whitespace a level of identation is worth
set shiftwidth=2

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


"------------------------------------------------------------------------------"
"                                  Key mapping                                 "
"------------------------------------------------------------------------------"

let mapleader = " "
nnoremap <leader>ff :Telescope find_files<CR>
nnoremap <leader>fg :Telescope git_files<CR>
nnoremap <leader>;; :CommentToggle<CR>
nnoremap <leader>cy yypk :CommentToggle<CR>j
nnoremap <leader>wh  <C-W>h
nnoremap <leader>wl  <C-W>l
nnoremap <leader>wj  <C-W>j
nnoremap <leader>wk  <C-W>k

" PLUGINS
call plug#begin('~/.vim/plugged')

" Fuzzy finder
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Nice comment frames
Plug 'cometsong/CommentFrame.vim'

" Colored parenthesis
Plug 'luochen1990/rainbow'

" Thin vertical lines at each indetation
Plug 'Yggdroot/indentLine'

" Emmet integration
Plug 'mattn/emmet-vim'

" Nice Syntax Highlighting
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}  " We recommend updating the parsers on update

" Nvim lsp configurations
Plug 'neovim/nvim-lspconfig'

" File Icons
Plug 'kyazdani42/nvim-web-devicons'

" Telescope Dependencies
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzy-native.nvim'

" Git integration
Plug 'tpope/vim-fugitive'
Plug 'stsewd/fzf-checkout.vim'

" Nice bottom line
Plug 'vim-airline/vim-airline'

" Color scheme
Plug 'flrnd/candid.vim'

" Comment
Plug 'terrortylor/nvim-comment'

" Linting and fixig
Plug 'dense-analysis/ale'

" Markdown preview
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}

call plug#end()

let g:rainbow_active = 1 "set to 0 if you want to enable it later via :RainbowToggle
let g:rainbow_conf = {
      \ 'guifgs': ['darkturquoise','deeppink1', 'dodgerblue1', 'orange1', 'limegreen', 'firebrick1']
      \}

colorscheme candid
set background=dark

set rtp+=~/tabnine-vim

lua require'lspconfig'.tsserver.setup{}
lua require'lspconfig'.pyright.setup{}
lua require'nvim_comment'.setup()

