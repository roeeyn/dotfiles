-- Specs for bujo.fold — `za` collapses a task's subtasks and nothing wider.
-- Run from the app config dir:
--   NVIM_APPNAME=bujo-nvim nvim --headless \
--     -u tests/minimal_init.lua \
--     -c "PlenaryBustedDirectory tests/ { minimal_init = 'tests/minimal_init.lua' }"
--
-- These specs drive REAL folds (tree-sitter foldexpr over the markdown
-- parser Neovim bundles, same `folds.scm` the app resolves), so they pin the
-- behaviour end to end rather than a reimplementation of it. The regression
-- that matters is the last one: before M.toggle() existed, `za` on a task
-- with no subtasks closed the enclosing section fold and the whole day's
-- note vanished.

local fold = require 'bujo.fold'

-- A note shaped like a real daily note: a heading, tasks with subtasks,
-- free-text children, and a childless task.
local LINES = {
    '# Friday, 2026-08-07', -- 1
    '', -- 2
    '- [ ] plan the offsite', -- 3
    '    - [ ] send invites', -- 4
    '    - [ ] book the room', -- 5
    '- [ ] renew the passport', -- 6
    '    - appointment slots open on the 12th', -- 7
    '- [ ] call the bank', -- 8
}

--- Load LINES into the current window with folding wired the way setup()
--- wires it. `zx` forces the foldexpr to run now instead of at the next
--- redraw, which never comes in a headless run.
local function open_note()
    vim.api.nvim_buf_set_lines(0, 0, -1, false, LINES)
    vim.bo.filetype = 'markdown'
    vim.wo.foldmethod = 'expr'
    vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    vim.wo.foldlevel = 99
    vim.cmd 'normal! zx'
end

local function cursor(lnum)
    vim.api.nvim_win_set_cursor(0, { lnum, 0 })
end

--- The visible fold at `lnum`, as { first, last } — or nil when nothing
--- around that line is collapsed.
local function closed_range(lnum)
    local first = vim.fn.foldclosed(lnum)
    if first == -1 then
        return nil
    end
    return { first, vim.fn.foldclosedend(lnum) }
end

describe('bujo.fold.starts_fold', function()
    before_each(open_note)

    it('is true on a task that has subtasks', function()
        assert.is_true(fold.starts_fold(3))
    end)

    it('is true on the next sibling task with subtasks', function()
        -- The reason this module asks the foldexpr instead of comparing
        -- foldlevel() with the previous line: line 6 sits at the same fold
        -- level as line 5, so a level comparison reports "no fold starts
        -- here" and `za` would go looking for an outer fold to close.
        assert.equals(vim.fn.foldlevel(5), vim.fn.foldlevel(6))
        assert.is_true(fold.starts_fold(6))
    end)

    it('is false on child lines and on a task with no subtasks', function()
        assert.is_false(fold.starts_fold(4))
        assert.is_false(fold.starts_fold(7))
        assert.is_false(fold.starts_fold(8))
    end)
end)

describe('bujo.fold.toggle', function()
    before_each(open_note)

    it('collapses exactly the task and its subtasks', function()
        cursor(3)
        fold.toggle()
        assert.same({ 3, 5 }, closed_range(3))
        -- The next task is untouched: the fold is the task's, not the list's.
        assert.is_nil(closed_range(6))
    end)

    it('expands again on a second press', function()
        cursor(3)
        fold.toggle()
        fold.toggle()
        assert.is_nil(closed_range(3))
    end)

    it('collapses a free-text child block too', function()
        cursor(6)
        fold.toggle()
        assert.same({ 6, 7 }, closed_range(6))
    end)

    it('does nothing on a task with no subtasks', function()
        -- The regression: plain `za` here closes the innermost fold that
        -- CONTAINS line 8 — the whole `- [ ]` list under the heading — so a
        -- press meant for one task would collapse the entire note.
        cursor(8)
        fold.toggle()
        for lnum = 1, #LINES do
            assert.is_nil(closed_range(lnum))
        end
    end)
end)
