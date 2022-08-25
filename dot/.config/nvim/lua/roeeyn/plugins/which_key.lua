local wk = require("which-key")

wk.register({
	f = {
		name = "File", -- optional group name
		f = { "<cmd>Telescope frecency workspace=CWD<cr>", "Find file using frecency" },
		s = { "Save current buffer" }, -- just a label. don't create any mapping
		["/"] = "Fuzzy search in current buffer", -- same as above
	},
	r = {
		name = "REPL",
		e = { "<cmd>CodiExpand<cr>", "Expand output of current line" },
		s = { "<cmd>CodiSelect<cr>", "Select filetype" },
		o = { "<cmd>Codi!!<cr>", "Open File in REPL" },
	},
	g = {
		name = "Git/GitHub",
		b = { "<cmd>G blame<cr>", "Git blame" },
		D = { "Diff Hunk" },
		m = { "See Git Message" },
		n = { "Next Hunk" },
		o = { "Preview Hunk" },
		p = { "Previous Hunk" },
		x = { "Undo Hunk" },
		y = { "Create GitHub Permalink" },
	},
	y = {
		h = { "<cmd>lua require('telescope').extensions.neoclip.default()<cr>", "Yank history" },
	},
}, { prefix = "<leader>" })
