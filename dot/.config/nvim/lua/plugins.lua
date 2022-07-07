local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'

if fn.empty(fn.glob(install_path)) > 0 then
  PACKER_BOOTSTRAP = fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
end

return require('packer').startup(function(use)
  -- My plugins here

  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- Nice indentation lines
  use 'lukas-reineke/indent-blankline.nvim'

  -- Theme for neovim
  use 'folke/tokyonight.nvim'

  -- Wakatime, code time tracking
  use 'wakatime/vim-wakatime'

  -- Nvim Treesitter for nice code traversal
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate'
  }

  -- Lualine for nice statusline in the bottom
  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'kyazdani42/nvim-web-devicons', opt = true }
  }

  -- Project viewer in the side
  use {
    'kyazdani42/nvim-tree.lua',
    requires = {
      {'kyazdani42/nvim-web-devicons', opt = true},
    },
  }

  -- Awesome testing
  use 'vim-test/vim-test'

  -- Nice Comment boxes inside the code
  use {
    's1n7ax/nvim-comment-frame',
    -- <leader>cf: Comment one line
    -- <leader>cm: Comment multiple lines
    requires = {
        { 'nvim-treesitter' }
    },
    config = function()
        require('nvim-comment-frame').setup()
    end
  }

  -- Commenting code easily
  use "terrortylor/nvim-comment"

  -- Documentation Generator
  use {
    'kkoomen/vim-doge',
    run = function()
        vim.fn['doge#install()'](0)
    end
  }

  -- Git integration
  -- :0Gclog to see revision of the file
  use 'tpope/vim-fugitive'

  -- Nice buffer deletion without closing the window
  use 'famiu/bufdelete.nvim'

  -- GitHub Copilot
  use 'github/copilot.vim'

  -- git gutter
  use 'airblade/vim-gitgutter'

  -- Harpoon
  use {
   'ThePrimeagen/harpoon',
    requires = { 'nvim-lua/plenary.nvim' }
  }

  -- Great fuzzy finder
  use {
    'junegunn/fzf',
    run = function()
      vim.fn['fzf#install'](0)
    end
  }
  use 'junegunn/fzf.vim'

  -- Telescope Dependencies
  use {
  'nvim-telescope/telescope.nvim',
    requires = {
      {'nvim-lua/plenary.nvim'},
      {'nvim-telescope/telescope-fzy-native.nvim'},
      { 'nvim-treesitter/nvim-treesitter', opt = true },
    }
  }

  -- Nice folding based on treesitter
  use {
    'kevinhwang91/nvim-ufo',
    requires = {
      { 'kevinhwang91/promise-async'},
      { 'nvim-treesitter/nvim-treesitter', opt = true },
    }
  }

  -- LSP configuration
  use 'neovim/nvim-lspconfig'


  --[[
  -- MISSING PLUGINS TO CONFIGURE:
    " Emmet
    Plug 'mattn/emmet-vim'

    " Git integration
    Plug 'stsewd/fzf-checkout.vim'

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
  --]]


  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if PACKER_BOOTSTRAP then
    require('packer').sync()
  end

  print('Plugins loaded')

end)
