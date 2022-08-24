----------------------------------------------------------------------
--                List of plugins used within NeoVim                --
----------------------------------------------------------------------

local fn = vim.fn
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"

if fn.empty(fn.glob(install_path)) > 0 then
	PACKER_BOOTSTRAP =
		fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
end

return require("packer").startup(function(use)
	-- My plugins here

	-- REPL for any languages
	use("metakirby5/codi.vim")

	-- Packer can manage itself
	use("wbthomason/packer.nvim")

	-- Nice indentation lines
	use("lukas-reineke/indent-blankline.nvim")

	-- Theme for neovim
	use("folke/tokyonight.nvim")

	-- Wakatime, code time tracking
	use("wakatime/vim-wakatime")

	-- Nvim Treesitter for nice code traversal
	use({
		"nvim-treesitter/nvim-treesitter",
		run = ":TSUpdate",
	})

	-- Lualine for nice statusline in the bottom
	use({
		"nvim-lualine/lualine.nvim",
		requires = { "kyazdani42/nvim-web-devicons", opt = true },
	})

	-- Project viewer in the side
	use({
		"kyazdani42/nvim-tree.lua",
		requires = {
			{ "kyazdani42/nvim-web-devicons", opt = true },
		},
	})

	-- Awesome testing
	use("vim-test/vim-test")

	-- Nice Comment boxes inside the code
	use({
		"s1n7ax/nvim-comment-frame",
		-- <leader>cf: Comment one line
		-- <leader>cm: Comment multiple lines
		requires = {
			{ "nvim-treesitter" },
		},
		config = function()
			require("nvim-comment-frame").setup()
		end,
	})

	-- Commenting code easily
	use("terrortylor/nvim-comment")

	-- Documentation Generator
	use({
		"kkoomen/vim-doge",
		-- run = ':call doge#install()',
		run = "npm i --no-save && npm run build:binary:unix",
	})

	-- Git integration
	-- :0Gclog to see revision of the file
	use("tpope/vim-fugitive")

	-- Nice buffer deletion without closing the window
	use("famiu/bufdelete.nvim")

	-- GitHub Copilot
	use("github/copilot.vim")

	-- git gutter
	use("airblade/vim-gitgutter")

	-- Harpoon
	use({
		"ThePrimeagen/harpoon",
		requires = { "nvim-lua/plenary.nvim" },
	})

	-- Great fuzzy finder
	use({
		"junegunn/fzf",
		run = function()
			vim.fn["fzf#install"](0)
		end,
	})
	use("junegunn/fzf.vim")

	-- Telescope Dependencies
	use({
		"nvim-telescope/telescope.nvim",
		requires = {
			{ "nvim-lua/plenary.nvim" },
			{ "nvim-telescope/telescope-fzy-native.nvim" },
			{ "nvim-treesitter/nvim-treesitter", opt = true },
		},
	})

	-- Nice folding based on treesitter
	use({
		"kevinhwang91/nvim-ufo",
		requires = {
			{ "kevinhwang91/promise-async" },
			{ "nvim-treesitter/nvim-treesitter", opt = true },
		},
	})

	-- LSP configuration
	use("neovim/nvim-lspconfig")

	-- Markdown preview
	use({
		"iamcco/markdown-preview.nvim",
		run = "cd app && npm install",
		setup = function()
			vim.g.mkdp_filetypes = { "markdown" }
		end,
		ft = { "markdown" },
	})

	-- Flutter
	use({ "akinsho/flutter-tools.nvim", requires = "nvim-lua/plenary.nvim" })

	-- Spacemacs like key
	use({
		"folke/which-key.nvim",
		config = function()
			require("which-key").setup({
				-- your configuration comes here
				-- or leave it empty to use the default settings
				-- refer to the configuration section below
			})
		end,
	})

	-- Completion
	use("hrsh7th/cmp-buffer")
	use("hrsh7th/cmp-cmdline")
	use("hrsh7th/cmp-git")
	use("hrsh7th/cmp-nvim-lsp")
	use("hrsh7th/cmp-nvim-lua")
	use("hrsh7th/cmp-path")
	use("hrsh7th/cmp-calc")
	use("hrsh7th/cmp-emoji")
	use("ray-x/cmp-treesitter")
	use("hrsh7th/nvim-cmp")

	-- Snippets
	use("L3MON4D3/LuaSnip")
	use("saadparwaiz1/cmp_luasnip")

	-- Debugger
	use("mfussenegger/nvim-dap")
	use("rcarriga/nvim-dap-ui")
	use("theHamsta/nvim-dap-virtual-text")
	use("mfussenegger/nvim-dap-python")
	use("nvim-telescope/telescope-dap.nvim")

	----------------------------------------------------------------------
	--                        Local plugins WIP                         --
	----------------------------------------------------------------------

	-- use "/Users/rodrigom/src/nvim-wakatime-worktree"
	use("roeeyn/nvim-wakatime-worktree")

	-- use "/Users/roeeyn/src/lua-tab-labeler/master"
	use("roeeyn/luatab-labeler")

	--[[
  -- MISSING PLUGINS TO CONFIGURE:
    " Emmet
    Plug 'mattn/emmet-vim'

    " Git integration
    Plug 'stsewd/fzf-checkout.vim'

  --]]

	-- Automatically set up your configuration after cloning packer.nvim
	-- Put this at the end after all plugins
	if PACKER_BOOTSTRAP then
		require("packer").sync()
	end

	print("Plugins loaded from Packer")
end)
