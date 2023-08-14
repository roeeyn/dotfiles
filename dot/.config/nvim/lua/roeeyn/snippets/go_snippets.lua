----------------------------------------------------------------------
--                         Golang Snippets                          --
----------------------------------------------------------------------

local ls = require 'luasnip'

ls.add_snippets('go', {
    ls.parser.parse_snippet('ie', 'if err != nil {\n  return err\n}'),
}, {
    key = 'go',
})
