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

local sn = ls.snippet_node

-- This is a format node
-- It takes a format string, and a list of nodes
-- fmt(<fmt_string>, {...nodes})
local fmt = require('luasnip.extras.fmt').fmt
--
-- Give us a list of selections from a list
local c = ls.choice_node

-- This is an insert node
-- it takes a position (like $1) and optionally some default text
-- i(<position>, [default_text])
local i = ls.insert_node

-- Set a text node
local t = ls.text_node

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

ls.add_snippets('gitcommit', {
  s(
    'conv',
    fmt('{}{}{}: {}', {
      c(1, {
        t 'feat',
        t 'fix',
        t 'chore',
        t 'docs',
        t 'build',
        t 'ci',
        t 'perf',
        t 'refactor',
        t 'revert',
        t 'style',
        t 'test',
      }),
      c(2, {
        sn(2, {
          t '(',
          i(1),
          t ')',
        }),
        t '',
      }),
      c(3, {
        t '!',
        t '',
      }),
      i(4, 'your Commit'),
    })
  ),
}, {
  key = 'gitcommit',
})
