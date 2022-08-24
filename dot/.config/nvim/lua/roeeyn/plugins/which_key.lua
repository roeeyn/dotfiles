local wk = require("which-key")

wk.register({
	f = {
		name = "File", -- optional group name
		s = { "Save current buffer" }, -- just a label. don't create any mapping
		["/"] = "Fuzzy search in current buffer", -- same as above
	},
	r = {
		name = "REPL",
		e = { "<cmd>CodiExpand<cr>", "Expand output of current line" },
		s = { "<cmd>CodiSelect<cr>", "Select filetype" },
		o = { "<cmd>Codi!!<cr>", "Open File in REPL" },
	},
}, { prefix = "<leader>" })
