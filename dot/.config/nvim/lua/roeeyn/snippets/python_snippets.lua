----------------------------------------------------------------------
--                         Python Snippets                          --
----------------------------------------------------------------------

local ls = require("luasnip")

-- This is a snippet creator
-- s(<trigger>, <nodes>)
local s = ls.snippet

-- This is a format node
-- It takes a format string, and a list of nodes
-- fmt(<fmt_string>, {...nodes})
local fmt = require("luasnip.extras.fmt").fmt

-- This is an insert node
-- it takes a position (like $1) and optionally some default text
-- i(<position>, [default_text])
local i = ls.insert_node

-- Repeats a node
-- rep(<position>)
local rep = require("luasnip.extras").rep

-- Give us a list of selections from a list
local c = ls.choice_node

-- Set a text node
local t = ls.text_node

ls.add_snippets("python", {
	s(
		"fprint",
		fmt(
			[[
    print("{}"*88)
    print("{}:", {})
    print("{}"*88)
  ]],
			{
				c(1, { t("*"), t("!"), t("/"), t("%") }),
				i(2),
				rep(2),
				rep(1),
			}
		)
	),
}, {
	key = "python",
})
