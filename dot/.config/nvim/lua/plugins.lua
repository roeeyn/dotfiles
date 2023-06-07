----------------------------------------------------------------------
--                List of plugins used within NeoVim                --
----------------------------------------------------------------------

local install_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'
local is_bootstrap = false

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  is_bootstrap = true
  vim.fn.system { 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path }
  vim.cmd [[packadd packer.nvim]]
end

require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- My plugins here
  -- Test Coverage
  use {
    'andythigpen/nvim-coverage',
    requires = 'nvim-lua/plenary.nvim',
    -- Optional: needed for PHP when using the cobertura parser
    rocks = { 'lua-xmlreader' },
    config = function()
      require('coverage').setup()
    end,
  }

  use 'windwp/nvim-ts-autotag'

  -- Clipboard/yank history
  use {
    'AckslD/nvim-neoclip.lua',
    requires = {
      { 'nvim-telescope/telescope.nvim' },
    },
    config = function()
      require('neoclip').setup()
    end,
  }

  -- Package json info
  use {
    'vuki656/package-info.nvim',
    requires = 'MunifTanjim/nui.nvim',
  }

  -- Optimization Plugin
  use 'lewis6991/impatient.nvim'

  -- Nice indentation lines
  use 'lukas-reineke/indent-blankline.nvim'

  -- Theme for neovim
  use 'folke/tokyonight.nvim'

  -- Wakatime, code time tracking
  use 'wakatime/vim-wakatime'

  -- Nvim Treesitter for nice code traversal
  use { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    run = function()
      pcall(require('nvim-treesitter.install').update { with_sync = true })
    end,
  }
  use 'nvim-treesitter/playground'

  -- Nvim treesitter context
  use 'nvim-treesitter/nvim-treesitter-context'

  use {
    'kyazdani42/nvim-web-devicons',
    config = function()
      require('nvim-web-devicons').setup()
    end,
  }

  -- Lualine for nice statusline in the bottom
  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'kyazdani42/nvim-web-devicons', opt = true },
  }

  -- File browser
  use {
    'nvim-tree/nvim-tree.lua',
    requires = { 'kyazdani42/nvim-web-devicons', opt = true },
  }

  -- Nice dashboard
  use {
    'goolord/alpha-nvim',
    config = function()
      require('roeeyn.plugins.alpha').setup()
    end,
  }

  -- Awesome testing
  use 'vim-test/vim-test'

  -- Nice Comment boxes inside the code
  use {
    's1n7ax/nvim-comment-frame',
    -- <leader>cf: Comment one line
    -- <leader>cm: Comment multiple lines
    requires = {
      { 'nvim-treesitter' },
    },
    config = function()
      require('nvim-comment-frame').setup()
    end,
  }

  -- Commenting code easily
  use 'terrortylor/nvim-comment'

  -- Documentation Generator
  use {
    'kkoomen/vim-doge',
    run = ':call doge#install()',
    -- run = 'npm i --no-save && npm run build:binary:unix',
  }

  -- Git integration
  -- :0Gclog to see revision of the file
  use 'tpope/vim-fugitive'
  use 'tpope/vim-rhubarb'
  use 'rhysd/git-messenger.vim'
  use {
    'ruifm/gitlinker.nvim',
    requires = 'nvim-lua/plenary.nvim',
  }

  -- GitHub Copilot
  use { 'zbirenbaum/copilot.lua' }
  use {
    'zbirenbaum/copilot-cmp',
    after = { 'copilot.lua' },
    config = function()
      require('copilot_cmp').setup {
        formatters = {
          insert_text = require('copilot_cmp.format').remove_existing,
        },
      }
    end,
  }

  -- git gutter
  use 'airblade/vim-gitgutter'

  -- Nice buffer deletion without closing the window
  use 'famiu/bufdelete.nvim'

  -- Harpoon
  use {
    'ThePrimeagen/harpoon',
    requires = { 'nvim-lua/plenary.nvim' },
  }

  -- Great fuzzy finder
  use 'junegunn/fzf.vim'

  -- Telescope Dependencies
  use {
    'nvim-telescope/telescope.nvim',
    requires = {
      { 'nvim-lua/plenary.nvim' },
    },
  }

  -- Fuzzy Finder Algorithm which requires local dependencies to be built. Only load if `make` is available
  use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make', cond = vim.fn.executable 'make' == 1 }

  use 'nvim-telescope/telescope-media-files.nvim'
  use 'nvim-telescope/telescope-symbols.nvim'

  -- Nice folding based on treesitter
  use {
    'kevinhwang91/nvim-ufo',
    requires = {
      { 'kevinhwang91/promise-async' },
      { 'nvim-treesitter/nvim-treesitter', opt = true },
    },
  }

  -- LSP configuration
  use { -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    requires = {
      -- Automatically install LSPs to stdpath for neovim
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',

      -- For formatting and linting
      'jose-elias-alvarez/null-ls.nvim',

      -- Useful status updates for LSP
      'j-hui/fidget.nvim',

      -- Additional lua configuration, makes nvim stuff amazing
      'folke/neodev.nvim',
    },
  }

  -- Markdown preview
  use {
    'iamcco/markdown-preview.nvim',
    run = 'cd app && npm install',
    setup = function()
      vim.g.mkdp_filetypes = { 'markdown' }
    end,
    ft = { 'markdown' },
  }

  -- Flutter
  use { 'akinsho/flutter-tools.nvim', requires = 'nvim-lua/plenary.nvim' }

  -- Spacemacs like key
  use {
    'folke/which-key.nvim',
    config = function()
      require('which-key').setup {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      }
    end,
  }

  -- Completion
  use {
    'hrsh7th/nvim-cmp',
    requires = {
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-cmdline',
      'hrsh7th/cmp-git',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-nvim-lua',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-calc',
      'hrsh7th/cmp-emoji',
      'ray-x/cmp-treesitter',
      -- Snippets
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
    },
  }

  -- Nice icons for cmp window
  use 'onsails/lspkind.nvim'

  -- Debugger
  use 'mfussenegger/nvim-dap'
  use 'rcarriga/nvim-dap-ui'
  use 'theHamsta/nvim-dap-virtual-text'
  use 'mfussenegger/nvim-dap-python'
  use 'nvim-telescope/telescope-dap.nvim'

  -- Nice tab
  use { 'alvarosevilla95/luatab.nvim', requires = 'kyazdani42/nvim-web-devicons' }

  -- Luv docs
  use 'nanotee/luv-vimdocs'

  ----------------------------------------------------------------------
  --                        Local plugins WIP                         --
  ----------------------------------------------------------------------
  -- use '/Users/roeeyn/src/nvim-config-tutor'

  -- Add custom plugins to packer from ~/.config/nvim/lua/custom/plugins.lua
  local has_plugins, plugins = pcall(require, 'custom.plugins')
  if has_plugins then
    plugins(use)
  end

  if is_bootstrap then
    require('packer').sync()
  end

  print 'Plugins loaded from Packer'
end)

-- When we are bootstrapping a configuration, it doesn't
-- make sense to execute the rest of the init.lua.
--
-- You'll need to restart nvim, and then it will work.
if is_bootstrap then
  print '=================================='
  print '    Plugins are being installed'
  print '    Wait until Packer completes,'
  print '       then restart nvim'
  print '=================================='
  return
end

require 'roeeyn'
