" Needed settings for font issues (Telescope)
set encoding=utf-8
" let g:airline_powerline_fonts = 1

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
nnoremap <leader>bd <cmd>bd<CR>
nnoremap <leader>wo <C-W>o
nnoremap <leader>el <cmd>lua vim.lsp.diagnostic.set_loclist()<CR>
nnoremap <leader>ec <cmd>lclose<CR>
nnoremap <leader>bp <cmd>bp<CR>
nnoremap <leader>bn <cmd>bn<CR>
nnoremap <leader>= <cmd>FormatWrite<CR>
nnoremap <leader>dp <cmd>Pydocstring<CR>
nnoremap <leader>pt <cmd>Vexplore<CR>

" PLUGINS
call plug#begin('~/.vim/plugged')

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

" Markdown preview
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install'  }

call plug#end()

colorscheme candid
set background=dark

lua require'formatter'.setup{
  \logging = true,
  \filetype = {
  \  proto = {
  \    function()
  \      return {
  \         exe = "clang-format",
  \         args = {"", vim.api.nvim_buf_get_name(0), ""},
  \         stdin = false
  \      }
  \    end
  \  },
  \  python = {
  \    function()
  \      return {
  \         exe = "black",
  \         args = {"", vim.api.nvim_buf_get_name(0), ""},
  \         stdin = false
  \      }
  \    end
  \  }
  \}
\}

let g:pydocstring_formatter = 'google'
let g:ycm_autoclose_preview_window_after_insertion = 1

let g:rainbow_active = 1 "set to 0 if you want to enable it later via :RainbowToggle
let g:rainbow_conf = {
      \ 'guifgs': ['darkturquoise','deeppink1', 'dodgerblue1', 'orange1', 'limegreen', 'firebrick1']
      \}

set rtp+=~/tabnine-vim

lua require'lspconfig'.tsserver.setup{}
lua require'nvim_comment'.setup()
lua require'lspconfig'.pyright.setup{
      \settings = {
      \python = {
      \venv_path = '~/.pyenv/versions'
      \}
      \}
    \}
lua  require'lspconfig'.jsonls.setup {
    \ commands = {
    \ Format = {
    \ function()
    \ vim.lsp.buf.range_formatting({},{0,0},{vim.fn.line("$"),0})
    \ end
    \ }
    \ }
    \ }
