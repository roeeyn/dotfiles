local wk = require("which-key")

wk.register({
	f = {
		name = "File", -- optional group name
		s = { "Save current buffer" }, -- just a label. don't create any mapping
		["/"] = "Fuzzy search in current buffer", -- same as above
	},
}, { prefix = "<leader>" })
