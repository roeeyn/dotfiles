-- Specs for bujo.strike — the per-line strikethrough for [x]/[-] blocks.
-- Run from the app config dir:
--   NVIM_APPNAME=bujo-nvim nvim --headless \
--     -u tests/minimal_init.lua \
--     -c "PlenaryBustedDirectory tests/ { minimal_init = 'tests/minimal_init.lua' }"
--
-- The whole point of this module is captured by the `from` values below:
-- a struck line starts at its first non-blank column (the bullet), never at
-- column 1 of an indented line — that would strike the leading whitespace,
-- which is the render-markdown scope_highlight bug this module replaces.

local strike = require 'bujo.strike'

describe('bujo.strike.ranges', function()
    it('strikes done and irrelevant tasks, bullet to EOL', function()
        assert.same(
            {
                { row = 1, from = 1, to = 17 },
                { row = 3, from = 1, to = 21 },
            },
            strike.ranges {
                '- [x] ship the PR', -- 17 bytes
                '- [ ] call the bank',
                '- [-] cancelled thing', -- 21 bytes
            }
        )
    end)

    it('never strikes open, migrated, or scheduled tasks', function()
        assert.same(
            {},
            strike.ranges {
                '- [ ] open',
                '- [>] migrated elsewhere',
                '- [<] scheduled for later',
                'plain text outside any task',
            }
        )
    end)

    it('strikes children from their own bullet, not from column 1', function()
        local ranges = strike.ranges {
            '  - [-] local_dev#16 (/am-local-dev skill)',
            '        - waiting on Kyle feedback for this',
            '        - merged this morning without needing my review',
        }
        -- Parent: 2-space indent -> strike starts at column 3.
        -- Children: 8-space indent -> strike starts at column 9. If any of
        -- these `from`s regress to 1, the indent is being struck again.
        assert.same({
            { row = 1, from = 3, to = 42 },
            { row = 2, from = 9, to = 43 },
            { row = 3, from = 9, to = 55 },
        }, ranges)
    end)

    it('strikes the whole child block: subtasks, notes, free text', function()
        local ranges = strike.ranges {
            '- [x] plan the offsite',
            '    - [ ] send invites',
            '    - remember Luis is out on Friday',
            '        deeper free text',
            '- [ ] untouched sibling',
        }
        assert.same(
            { 1, 2, 3, 4 },
            vim.tbl_map(function(r)
                return r.row
            end, ranges)
        )
        -- The open subtask is struck too: its parent block is dead.
        assert.same(
            { 1, 5, 5, 9 },
            vim.tbl_map(function(r)
                return r.from
            end, ranges)
        )
    end)

    it('a struck child under an open parent strikes only its own block', function()
        local ranges = strike.ranges {
            '- [ ] parent still open',
            '    - [x] done child',
            '        - note under the done child',
            '    - [ ] open child',
        }
        assert.same(
            { 2, 3 },
            vim.tbl_map(function(r)
                return r.row
            end, ranges)
        )
    end)

    it('a blank line ends the block, same as bujo.migrate', function()
        local ranges = strike.ranges {
            '- [-] dropped plan',
            '',
            '    - dedented-after-blank: NOT part of the block',
            '- [ ] next task',
        }
        -- Only the task line itself is struck: migrate.lua ends a block at
        -- the first blank line (see "ends a block at a blank line" spec),
        -- and strike must agree with migration about what belongs to a task.
        assert.same(
            { 1 },
            vim.tbl_map(function(r)
                return r.row
            end, ranges)
        )
    end)

    it('handles a bare marker with no text and non-task lookalikes', function()
        assert.same(
            {
                { row = 1, from = 1, to = 5 },
            },
            strike.ranges {
                '- [x]', -- valid: marker at EOL
                '- [x]:not a task (no space after the marker)',
                'x - [x] not at line start after text',
            }
        )
    end)
end)

describe('bujo.strike.decorate', function()
    it('places one extmark per struck line at the computed columns', function()
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
            '- [x] done task',
            '    - child note',
            '- [ ] open task',
        })

        strike.decorate(buf)

        local ns = vim.api.nvim_get_namespaces()['bujo-strike']
        local marks = vim.api.nvim_buf_get_extmarks(buf, ns, 0, -1, { details = true })
        -- {mark_id, row, col} with 0-based positions; end_col is exclusive.
        assert.equal(2, #marks)
        assert.same({ 0, 0 }, { marks[1][2], marks[1][3] })
        assert.equal(15, marks[1][4].end_col)
        assert.same({ 1, 4 }, { marks[2][2], marks[2][3] })
        assert.equal(16, marks[2][4].end_col)

        -- Recompute after a change clears stale marks instead of stacking.
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, { '- [ ] nothing done yet' })
        strike.decorate(buf)
        assert.same({}, vim.api.nvim_buf_get_extmarks(buf, ns, 0, -1, {}))
    end)
end)
