----------------------------------------------------------------------
--                           Lua Snippets                           --
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

-- This is a function node. You can calculate the snippet result.
--
-- The first argument is a function that takes a list of args.
-- Function nodes always return a string to insert
local f = ls.function_node

ls.add_snippets("lua", {
	s(
		"req",
		fmt([[local {} = require("{}")]], {
			f(function(import_name)
				local parts = vim.split(import_name[1][1], ".", true)
				return parts[#parts] or "" -- last element of the split table
			end, { 1 }), -- node index
			i(1),
		})
	),
}, {
	key = "lua",
})
