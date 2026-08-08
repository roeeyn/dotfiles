-- bujo/fold.lua — collapse a task's subtasks with `za`.
--
-- Folding is a VIEW concern, so unlike strike.lua and priority.lua this
-- module owns no block rule of its own: the folds come from tree-sitter's
-- markdown `folds.scm` (`(list_item (list))` — a list item that contains a
-- nested list, i.e. exactly "a task with subtasks", plus `(section)` for
-- headings and code blocks). Neovim ships that query with the bundled
-- markdown parser, so the specs see the same folds the app does.
--
-- Consequence worth knowing: tree-sitter's list_item can span a blank line
-- (a "loose" list), so a fold may cover a line migrate.lua/strike.lua would
-- exclude from the task's block. That divergence is fine and deliberate —
-- do NOT chase parity with migrate.lua here. Migration semantics decide what
-- *moves between days*; folds only decide what is hidden on screen.
--
-- Why `za` is remapped instead of used as-is: fold levels nest, so on a task
-- with NO subtasks the innermost fold containing the cursor is the enclosing
-- `(section (list))` — plain `za` there collapses the entire day's note,
-- which is a startling answer to "collapse this task". M.toggle() only ever
-- touches a fold that STARTS on the cursor line, so `za` means "this task's
-- subtasks" and nothing else. `zc`/`zo`/`zR`/`zM` keep their native meaning,
-- including "close the fold I'm inside" from a child line.
--
-- Collapsed indicator (three cooperating pieces, see setup()):
--   * `foldtext = ''` — the folded line is drawn through the normal line
--     path, so the checkbox icon, strikethrough and the `!` marker survive.
--     (Only *overlay* extmarks render on a closed fold; end-of-line virtual
--     text does not, which is why there is no "N hidden lines" suffix.)
--   * the `Folded` background plus the trailing `·` fill run.
--   * a `▾`/`▸` arrow from M.gutter(), rendered through 'statuscolumn'
--     rather than 'foldcolumn'. `foldcolumn = auto:1` looks right until you
--     read the gutter of a plain task: when a line sits deeper than the
--     column is wide, Neovim prints the fold LEVEL DIGIT there, so every
--     child line and every one-liner task grows a stray `2`/`3`. Widening
--     it to `auto:3` trades that for three mostly-blank columns and a
--     doubled `▾▾` wherever two folds start on one line. The statuscolumn
--     draws exactly one cell, and only for lines that actually fold.

local M = {}

M.config = {
    -- Gutter arrows, drawn by M.gutter() (see the header).
    open = '▾',
    closed = '▸',
    -- Everything starts unfolded; a note you just opened should read as
    -- written, not as an outline.
    foldlevel = 99,
}

--- True when a fold STARTS on `lnum` — the test behind `za`'s guard.
---
--- Asks tree-sitter's foldexpr rather than comparing `foldlevel()` across
--- neighbouring lines: two sibling tasks that both have subtasks sit at the
--- same fold level, so `foldlevel(lnum) > foldlevel(lnum - 1)` is false on
--- the second one even though a fold does start there. The foldexpr answers
--- with the `>N` ("a fold of level N starts here") form instead.
---@param lnum integer 1-based line number
---@return boolean
function M.starts_fold(lnum)
    local expr = vim.treesitter.foldexpr(lnum)
    return type(expr) == 'string' and expr:sub(1, 1) == '>'
end

--- `za`: collapse/expand the subtasks of the task under the cursor.
function M.toggle()
    local lnum = vim.fn.line '.'

    -- Closed already (the cursor sits on the one visible line of the fold):
    -- expand it.
    if vim.fn.foldclosed(lnum) ~= -1 then
        vim.cmd 'normal! zo'
        return
    end

    if M.starts_fold(lnum) then
        -- `zc` closes the innermost fold containing the cursor. On a line
        -- where several folds start (a task's own fold nests inside the
        -- list's), that is the deepest one — the task's subtasks, never the
        -- whole list.
        vim.cmd 'normal! zc'
        return
    end

    -- Nothing folds here: the cursor is on a task without subtasks, on a
    -- child line, or on free text. Do nothing, on purpose — `za` is inert
    -- rather than chatty. A `vim.notify` hint was considered and dropped
    -- (this app stays quiet while you work), and so was falling back to
    -- `normal! zc` to collapse the parent from a child line: that same
    -- fallback on a childless task collapses the whole day's note, which is
    -- the exact behaviour the guard above exists to prevent. `zc` still does
    -- it natively for anyone who wants it.
end

--- One gutter cell for 'statuscolumn', evaluated per line: `▸` when the
--- line is a collapsed fold, `▾` when it is a fold waiting to be collapsed,
--- a blank otherwise. Always exactly one cell wide — the numbers next to it
--- must not shift as folds open and close.
---
--- The filetype guard keeps the tree-sitter call off buffers that have no
--- markdown parser (oil, telescope previews), which a window inherits if it
--- switches away from a note.
function M.gutter()
    local lnum = vim.v.lnum
    if vim.fn.foldclosed(lnum) == lnum then
        return M.config.closed
    end
    if vim.bo.filetype == 'markdown' and M.starts_fold(lnum) then
        return M.config.open
    end
    return ' '
end

function M.setup(opts)
    M.config = vim.tbl_deep_extend('force', M.config, opts or {})

    -- Fold options are set globally: `:set` on a window-local option also
    -- becomes the default for windows opened later, so splits inherit
    -- folding without a per-window autocmd. On buffers with no markdown
    -- parser (oil, telescope) the foldexpr answers 0 — no folds, no change.
    vim.opt.foldmethod = 'expr'
    vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    vim.opt.foldlevel = M.config.foldlevel
    -- Empty foldtext keeps render-markdown's icons, strike.lua's line and
    -- priority.lua's marker on the collapsed line; the built-in
    -- `+--  3 lines: - [ ] ...` would replace all of it with raw markdown.
    -- The trailing `·` run past the text comes from the default
    -- `fillchars` `fold:·`, and is half the "this is collapsed" signal.
    vim.opt.foldtext = ''

    local group = vim.api.nvim_create_augroup('bujo-fold', { clear = true })
    vim.api.nvim_create_autocmd('FileType', {
        group = group,
        pattern = 'markdown',
        callback = function(a)
            vim.keymap.set('n', 'za', M.toggle, {
                buffer = a.buf,
                desc = "Toggle the current task's subtasks",
            })
            -- Arrow, then the number column this app already had
            -- (`number` + `relativenumber`: relative everywhere, absolute on
            -- the cursor line). Window-local, so buffers without folds keep
            -- the stock gutter; splits copy it from the window they open in.
            vim.opt_local.statuscolumn = '%s%{%v:lua.require("bujo.fold").gutter()%}%=%{v:relnum ? v:relnum : v:lnum} '
        end,
    })
end

return M
