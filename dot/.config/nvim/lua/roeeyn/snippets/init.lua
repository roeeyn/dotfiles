----------------------------------------------------------------------
--                          Snippets Init                           --
----------------------------------------------------------------------

require 'roeeyn.snippets.python_snippets'
require 'roeeyn.snippets.lua_snippets'
require 'roeeyn.snippets.js_snippets'

local ls = require 'luasnip'
--
-- This is a snippet creator
-- s(<trigger>, <nodes>)
local s = ls.snippet

-- This is a function node. You can calculate the snippet result.
--
-- The first argument is a function that takes a list of args.
-- Function nodes always return a string to insert
local f = ls.function_node

ls.add_snippets('all', {
  ls.parser.parse_snippet('qelv', '¡¡tú eres la mera vrg papirrin!!'),
  s(
    'curtime',
    f(function()
      return os.date '%D - %H:%M'
    end)
  ),
}, {
  key = 'all',
})
