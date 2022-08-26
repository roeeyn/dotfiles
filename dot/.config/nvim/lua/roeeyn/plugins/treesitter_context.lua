require("treesitter-context").setup({
	enable = true,
	max_lines = 0, -- no max lines if <= 0
	zindex = 50,
	patterns = {
		default = {
			"class",
			"function",
			"method",
			"for",
			"while",
			"if",
			"switch",
			"case",
			"else",
		},
		python = {
			"with",
			"try",
			"except",
			"elif",
		},
	},
	exact_patterns = {
		python = true,
	},
})
