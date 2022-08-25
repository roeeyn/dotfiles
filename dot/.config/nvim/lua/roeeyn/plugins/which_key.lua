local wk = require("which-key")

wk.register({
	c = {
		name = "Code",
		a = { "<cmd>lua vim.lsp.buf.code_action()<cr>", "Diagnostics Action" },
		s = { "<cmd>lua vim.lsp.buf.signature_help()<cr>", "Signature help" },
		t = { "<cmd>lua vim.lsp.buf.hover()<cr>", "Hover Info" },
		D = { "<cmd>lua vim.lsp.buf.declaration()<cr>", "Go To Declaration" },
		R = { "<cmd>lua vim.lsp.buf.rename()<cr>", "Rename definition" },
	},
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
	w = {
		name = "Window",
		T = { "<cmd>Twilight<cr>", "Toggle Twilight" },
	},
	y = {
		h = { "<cmd>lua require('telescope').extensions.neoclip.default()<cr>", "Yank history" },
	},
}, { prefix = "<leader>" })
