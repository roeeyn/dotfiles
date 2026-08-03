-- bujo/priority.lua — `!` priority marker for tasks.
--
-- Syntax: a `!` immediately after the checkbox marks the task important:
--
--     - [ ] !renew the passport
--
-- The marker lives in the task TEXT, not inside the brackets, on purpose:
-- the bracket char is a state machine owned by migrate.lua (only `[ ]`
-- migrates), toggle (only `[ ]`<->`[x]`) and pick_tasks (only `[ ]` listed).
-- A `[!]` state would have to be taught to all three and would be destroyed
-- the moment the task is toggled done. Text rides along for free: migration
-- copies lines verbatim, so the `!` follows the task across days, and a done
-- important task is naturally expressible as `- [x] !...`.
--
-- Rendering: the `!` is painted over with an icon via `virt_text_pos =
-- 'overlay'` — overlay replaces the cell WITHOUT changing line width, so
-- soft-wrap stays honest. Conceal would not (neovim wraps on raw buffer
-- columns even under conceal, neovim/neovim#14409 — the same reason
-- links.lua keeps refs bare). While the task is pending, the whole task text
-- is highlighted too; once resolved ([x]/[-]) only a muted icon remains and
-- strike.lua's strikethrough takes over — done work should stop shouting.
--
-- Rendering strategy: persistent extmarks recomputed on every text change,
-- skipped in Insert/Replace mode so the raw `!` is editable while typing —
-- same pattern and reasoning as strike.lua.

local M = {}

M.config = {
    -- Single-cell glyph painted over the `!`. Must stay one cell wide:
    -- overlay covers exactly the cells the virt_text occupies, so a wider
    -- icon would paint over the first letter of the task.
    icon = '',
    -- Per-checkbox-state treatment of an important task. A state that maps
    -- to nil (or is missing) renders nothing: the raw `!` stays visible,
    -- which is the safe fallback. `text_hl` is optional; without it only
    -- the icon is drawn.
    styles = {
        [' '] = { icon_hl = 'BujoPriority', text_hl = 'BujoPriority' },
        ['x'] = { icon_hl = 'BujoPriorityMuted' },
        ['-'] = { icon_hl = 'BujoPriorityMuted' },
        -- TODO(rodrigo): decide the treatment for migrated [>] and
        -- scheduled [<] important tasks. The work still exists elsewhere —
        -- should the pointer keep glowing (they'd re-shout every day the
        -- task keeps migrating), stay muted like done tasks, or keep the
        -- raw `!` (current behavior)? Pin your choice in
        -- tests/priority_spec.lua ("resolved states" spec) once made.
    },
}

local ns = vim.api.nvim_create_namespace 'bujo-priority'

--- Pure core, pinned by tests/priority_spec.lua: every important task line,
--- as { row, col, to, state } — all 1-based byte columns, `col` pointing at
--- the `!`, `to` at the last byte of the line (inclusive, same convention as
--- strike.ranges / links.refs).
---@param lines string[]
---@return { row: integer, col: integer, to: integer, state: string }[]
function M.marks(lines)
    local out = {}
    for row, line in ipairs(lines) do
        -- `!` must sit immediately after `] ` — anywhere else in the text a
        -- bang is just punctuation.
        local indent, state = line:match '^(%s*)%- %[(.)%] !'
        if state then
            out[#out + 1] = { row = row, col = #indent + 7, to = #line, state = state }
        end
    end
    return out
end

--- Re-scan `buf` and decorate every important task per its state's style.
--- Like strike.decorate, draws nothing in Insert/Replace mode — the mode
--- check lives here so a TextChangedI recompute can never re-add the overlay
--- while the raw `!` is being edited.
function M.decorate(buf)
    vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
    if vim.api.nvim_get_mode().mode:find '^[iR]' then
        return
    end
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    for _, m in ipairs(M.marks(lines)) do
        local style = M.config.styles[m.state]
        if style then
            vim.api.nvim_buf_set_extmark(buf, ns, m.row - 1, m.col - 1, {
                virt_text = { { M.config.icon, style.icon_hl } },
                virt_text_pos = 'overlay',
            })
            if style.text_hl then
                vim.api.nvim_buf_set_extmark(buf, ns, m.row - 1, m.col - 1, {
                    end_col = m.to,
                    hl_group = style.text_hl,
                })
            end
        end
    end
end

function M.setup(opts)
    M.config = vim.tbl_deep_extend('force', M.config, opts or {})

    vim.api.nvim_set_hl(0, 'BujoPriority', { default = true, link = 'DiagnosticWarn' })
    vim.api.nvim_set_hl(0, 'BujoPriorityMuted', { default = true, link = 'NonText' })

    local group = vim.api.nvim_create_augroup('bujo-priority', { clear = true })
    vim.api.nvim_create_autocmd('FileType', {
        group = group,
        pattern = 'markdown',
        callback = function(a)
            M.decorate(a.buf)
            if vim.b[a.buf].bujo_priority then
                return
            end
            vim.b[a.buf].bujo_priority = true
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
