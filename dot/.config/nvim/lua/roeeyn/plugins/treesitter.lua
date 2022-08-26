-- Treesitter configuration
require("nvim-treesitter.configs").setup({
	highlight = { enable = true },
	-- indent = {enable = true}
	autotag = {
		enable = true,
	},
	textsubjects = {
		enable = true,
		prev_selection = ",", -- (Optional) keymap to select the previous selection
		keymaps = {
			["."] = "textsubjects-smart",
			[";"] = "textsubjects-container-outer",
			["i;"] = "textsubjects-container-inner",
		},
	},
	playground = {
		enable = true,
	},
})
