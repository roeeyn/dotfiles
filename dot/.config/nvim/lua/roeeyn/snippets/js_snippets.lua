----------------------------------------------------------------------
--                          JS/TS Snippets                          --
----------------------------------------------------------------------

local ls = require("luasnip")

-- This is a snippet creator
-- s(<trigger>, <nodes>)
local s = ls.snippet

local sn = ls.snippet_node

-- This is a format node
-- It takes a format string, and a list of nodes
-- fmt(<fmt_string>, {...nodes})
local fmt = require("luasnip.extras.fmt").fmt

-- Give us a list of selections from a list
local c = ls.choice_node

-- Set a text node
local t = ls.text_node

-- This is an insert node
-- it takes a position (like $1) and optionally some default text
-- i(<position>, [default_text])
local i = ls.insert_node

ls.add_snippets("typescript", {
	s(
		"afun",
		fmt("{}const {} = ({}){} => {}", {
			c(1, { t("export "), t("") }),
			i(2),
			i(3),
			c(4, { sn(4, { t(": "), i(1) }), t("") }),
			c(5, { i(5), sn(5, { t("{ "), i(1), t(" }") }) }),
		})
	),
}, {
	key = "typescript",
})
