-- bujo/strike.lua — per-line strikethrough for done/irrelevant tasks.
--
-- Why this module exists (instead of render-markdown's `scope_highlight`):
-- render-markdown highlights a checkbox's "scope" with ONE extmark spanning
-- the item's whole inline node (Render:scope -> Marks:over). A single
-- multi-line extmark covers every byte between its endpoints, so on wrapped
-- or indented child lines the strikethrough runs from column 0 THROUGH THE
-- LEADING WHITESPACE, which looks like this:
--
--     󰩹 l̶o̶c̶a̶l̶_̶d̶e̶v̶#̶1̶6̶ ̶(̶s̶k̶i̶l̶l̶)̶
--     ̶ ̶ ̶ ̶ ̶ ̶ ̶ ̶-̶ ̶w̶a̶i̶t̶i̶n̶g̶ ̶o̶n̶ ̶K̶y̶l̶e̶      <- indent struck too
--
-- The plugin has no option to trim that (checked at commit f422cb5), so we
-- own the strike instead: one extmark PER LINE, starting at the first
-- non-blank column (the bullet) and ending at EOL:
--
--     󰩹 l̶o̶c̶a̶l̶_̶d̶e̶v̶#̶1̶6̶ ̶(̶s̶k̶i̶l̶l̶)̶
--             -̶ ̶w̶a̶i̶t̶i̶n̶g̶ ̶o̶n̶ ̶K̶y̶l̶e̶    <- indent untouched
--
-- render-markdown keeps rendering the checkbox icons/colors; only the
-- `scope_highlight` entries were removed from its config in favor of this
-- (see lua/plugins/render-markdown.lua).
--
-- What gets struck:
--   * every `- [x]` (done) and `- [-]` (irrelevant) task line, and
--   * every line of its child block — subsequent lines indented deeper than
--     the task, including plain `- ` note bullets and free text. The block
--     ends at the first blank line or at the first line indented at or
--     above the task's level — the exact block rule bujo/migrate.lua uses,
--     so the lines that would migrate together are the lines that strike
--     together.
--   * `[>]` (migrated) and `[<]` (scheduled) are deliberately NOT struck:
--     they are pointers to work that still exists elsewhere, not dead text.
--
-- Rendering strategy: persistent extmarks recomputed on every text change,
-- NOT an ephemeral decoration provider — same pattern and reasoning as
-- links.lua (see "Gotchas" in CLAUDE.md). Notes are tiny; whole-buffer
-- recompute is cheap.

local M = {}

M.config = {
    -- Highlight applied to struck lines. BujoStrike default-links to the
    -- same group render-markdown's scope_highlight used, so the look is
    -- unchanged — only the range is different.
    highlight = 'BujoStrike',
    -- Checkbox state characters (the char between the brackets) that strike
    -- their whole block.
    states = { 'x', '-' },
}

local ns = vim.api.nvim_create_namespace 'bujo-strike'

-- A task line is `<indent>- [<state>]` followed by end-of-line or a space.
-- Returns indent, state — or nil for non-task lines.
local function task_line(line)
    local indent, state = line:match '^(%s*)%- %[(.)%]'
    if state and (line:match '^%s*%- %[.%]$' or line:match '^%s*%- %[.%] ') then
        return indent, state
    end
    return nil, nil
end

local function is_struck_state(state)
    return vim.tbl_contains(M.config.states, state)
end

--- Pure core, pinned by tests/strike_spec.lua: given the buffer lines,
--- return the strike ranges as { row, from, to } (all 1-based, byte-indexed,
--- `to` inclusive — the same shape links.refs() uses). One entry per line;
--- `from` is the first non-blank column, so indentation is never covered.
---@param lines string[]
---@return { row: integer, from: integer, to: integer }[]
function M.ranges(lines)
    local out, seen = {}, {}

    local function add(row)
        if seen[row] then
            return
        end
        local line = lines[row]
        local indent = line:match '^%s*'
        if #indent == #line then
            return -- blank: nothing to strike
        end
        seen[row] = true
        out[#out + 1] = { row = row, from = #indent + 1, to = #line }
    end

    for row, line in ipairs(lines) do
        local indent, state = task_line(line)
        if indent and is_struck_state(state) then
            add(row)
            -- The task's child block: subsequent deeper-indented lines. A
            -- blank line or a line at/above the task's indent ends the
            -- block — the same rule as migrate.lua, so strike and migration
            -- always agree on what belongs to a task.
            for child = row + 1, #lines do
                local cline = lines[child]
                local cindent = cline:match '^%s*'
                if #cindent == #cline or #cindent <= #indent then
                    break
                end
                add(child)
            end
        end
    end

    -- Extmarks could be set in any order, but sorted output keeps the specs
    -- readable and diffs deterministic.
    table.sort(out, function(a, b)
        return a.row < b.row
    end)
    return out
end

--- Re-scan `buf` and strike every done/irrelevant task block, bullet-to-EOL.
--- Strikes render only in Normal(-ish) modes: while typing (Insert/Replace)
--- the whole buffer is left unstruck, because watching your own words get
--- crossed out as you write under a done task is distracting. The mode check
--- lives HERE, not in the autocmds, so a TextChangedI recompute can never
--- re-add marks mid-insert.
function M.decorate(buf)
    vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
    if vim.api.nvim_get_mode().mode:find '^[iR]' then
        return
    end
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    for _, r in ipairs(M.ranges(lines)) do
        vim.api.nvim_buf_set_extmark(buf, ns, r.row - 1, r.from - 1, {
            end_col = r.to,
            hl_group = M.config.highlight,
        })
    end
end

function M.setup(opts)
    M.config = vim.tbl_deep_extend('force', M.config, opts or {})

    -- Same face render-markdown's scope_highlight produced; strikethrough
    -- combines additively with whatever other highlights are on the text.
    vim.api.nvim_set_hl(0, 'BujoStrike', { default = true, link = '@markup.strikethrough' })

    local group = vim.api.nvim_create_augroup('bujo-strike', { clear = true })
    vim.api.nvim_create_autocmd('FileType', {
        group = group,
        pattern = 'markdown',
        callback = function(a)
            M.decorate(a.buf)
            if vim.b[a.buf].bujo_strike then
                return
            end
            vim.b[a.buf].bujo_strike = true
            -- InsertEnter/InsertLeave drive the mode transitions; decorate()
            -- itself decides whether marks are drawn, so all four events can
            -- share the same callback.
            vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI', 'InsertEnter', 'InsertLeave' }, {
                group = group,
                buffer = a.buf,
                callback = function()
                    M.decorate(a.buf)
                end,
            })
        end,
    })
end

return M
