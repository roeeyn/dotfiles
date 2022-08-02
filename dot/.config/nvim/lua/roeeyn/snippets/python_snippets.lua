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
		"sfprint",
		fmt(
			[[
    print("{}:", {})
  ]],
			{
				i(1),
				rep(1),
			}
		)
	),
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
	s(
		"def",
		fmt(
			[[
    def {}({}){}:
        pass
  ]],
			{
				i(1),
				c(2, { i(2), t("self") }),
				c(3, {
					t(""),
					t(" -> None"),
					t(" -> int | None"),
					t(" -> str"),
					t(" -> str | None"),
					t(" -> Any"),
				}),
			}
		)
	),
	s(
		"handler",
		fmt(
			[[
    from __future__ import annotations

    {}
    {}


    class {}:
        INSTANCE: {}

        def __init__(self, logger: Logger) -> None:
            self._logger: Logger = logger


    {}.INSTANCE = {}(
      logger=logging.getLogger(__name__),
    )

  ]],
			{
				c(1, { t("from lyft_logging import logging"), t("import logging") }),
				c(2, {
					t("from lyft_logging.logging import StructuredKeyValueAdapter as Logger"),
					t("from logging import Logger"),
				}),
				i(3),
				rep(3),
				rep(3),
				rep(3),
			}
		)
	),
	s(
		"try",
		fmt(
			[[
    try:
        pass

    except {}:
        pass
  ]],
			{
				i(1),
			}
		)
	),
}, {
	key = "python",
})
