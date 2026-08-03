-- Specs for bujo.priority — the `!` priority marker.
-- Run from the app config dir:
--   NVIM_APPNAME=bujo-nvim nvim --headless \
--     -u tests/minimal_init.lua \
--     -c "PlenaryBustedDirectory tests/ { minimal_init = 'tests/minimal_init.lua' }"
--
-- The design decision pinned here: the marker is `!` in the task TEXT
-- (immediately after `] `), never a bracket state — so migrate/toggle/
-- pick_tasks need no knowledge of it, and a bang anywhere else in the text
-- is plain punctuation.

local priority = require 'bujo.priority'

describe('bujo.priority.marks', function()
    it('finds the `!` right after the checkbox, reporting its column', function()
        assert.same(
            {
                { row = 1, col = 7, to = 20, state = ' ' },
                { row = 3, col = 9, to = 17, state = ' ' },
            },
            priority.marks {
                '- [ ] !call the bank', -- 20 bytes, `!` at col 7
                '- [ ] normal task',
                '  - [ ] !pay rent', -- 17 bytes, 2-space indent -> `!` at col 9
            }
        )
    end)

    it('reports the checkbox state, for every state', function()
        local states = vim.tbl_map(
            function(m)
                return m.state
            end,
            priority.marks {
                '- [ ] !open',
                '- [x] !done',
                '- [-] !irrelevant',
                '- [>] !migrated',
                '- [<] !scheduled',
            }
        )
        assert.same({ ' ', 'x', '-', '>', '<' }, states)
    end)

    it('ignores bangs anywhere but immediately after "] "', function()
        assert.same(
            {},
            priority.marks {
                '- [ ] wow!', -- punctuation, not a marker
                '- [ ] a ! in the middle',
                '- [ ]!tight (no space after the checkbox)',
                '! not a task at all',
                '- plain note bullet, !even with a bang',
            }
        )
    end)
end)

describe('bujo.priority.decorate', function()
    local function marks_in(buf)
        local ns = vim.api.nvim_get_namespaces()['bujo-priority']
        local overlays, highlights = {}, {}
        for _, mk in ipairs(vim.api.nvim_buf_get_extmarks(buf, ns, 0, -1, { details = true })) do
            table.insert(mk[4].virt_text and overlays or highlights, mk)
        end
        return overlays, highlights
    end

    it('pending tasks get an icon overlay plus a text highlight', function()
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
            '- [ ] !urgent thing', -- 19 bytes
            '- [ ] not important',
        })

        priority.decorate(buf)
        local overlays, highlights = marks_in(buf)

        -- One icon painted over the `!` (0-based row 0, col 6), overlay so
        -- line width — and therefore soft-wrap — is unchanged.
        assert.equal(1, #overlays)
        assert.same({ 0, 6 }, { overlays[1][2], overlays[1][3] })
        assert.equal('overlay', overlays[1][4].virt_text_pos)
        assert.equal('BujoPriority', overlays[1][4].virt_text[1][2])

        -- And the task text highlighted from the `!` to EOL.
        assert.equal(1, #highlights)
        assert.same({ 0, 6 }, { highlights[1][2], highlights[1][3] })
        assert.equal(19, highlights[1][4].end_col)
    end)

    it('resolved tasks keep only a muted icon — no text highlight', function()
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
            '- [x] !shipped',
            '- [-] !dropped',
        })

        priority.decorate(buf)
        local overlays, highlights = marks_in(buf)

        assert.equal(2, #overlays)
        for _, mk in ipairs(overlays) do
            assert.equal('BujoPriorityMuted', mk[4].virt_text[1][2])
        end
        -- strike.lua owns the line treatment for [x]/[-]; priority adds no
        -- competing text highlight.
        assert.same({}, highlights)
    end)

    it('migrated and scheduled tasks render nothing (undecided, raw ! stays)', function()
        -- Placeholder pin for the open styles decision in priority.lua's
        -- config: until [>]/[<] get an entry, the raw `!` is left untouched.
        -- Update this spec when the decision lands.
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
            '- [>] !moved on',
            '- [<] !scheduled',
        })

        priority.decorate(buf)
        local overlays, highlights = marks_in(buf)
        assert.same({}, overlays)
        assert.same({}, highlights)
    end)

    it('recomputes instead of stacking, and draws nothing in Insert mode', function()
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, { '- [ ] !urgent' })
        local ns = vim.api.nvim_get_namespaces()['bujo-priority']

        priority.decorate(buf)
        priority.decorate(buf)
        assert.equal(2, #vim.api.nvim_buf_get_extmarks(buf, ns, 0, -1, {}))

        -- Mode is stubbed rather than entered — same reasoning as the
        -- Insert-mode spec in strike_spec.lua (startinsert is deferred in
        -- headless specs; feedkeys kills the runner).
        local real_get_mode = vim.api.nvim_get_mode
        vim.api.nvim_get_mode = function()
            return { mode = 'i', blocking = false }
        end
        local ok, err = pcall(priority.decorate, buf)
        vim.api.nvim_get_mode = real_get_mode
        assert(ok, err)
        assert.same({}, vim.api.nvim_buf_get_extmarks(buf, ns, 0, -1, {}))

        -- Back in (real) Normal mode the same call restores the marks.
        priority.decorate(buf)
        assert.equal(2, #vim.api.nvim_buf_get_extmarks(buf, ns, 0, -1, {}))
    end)
end)
