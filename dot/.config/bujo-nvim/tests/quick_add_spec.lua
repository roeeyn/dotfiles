-- Specs for bujo.quick_add — cursor-relative task insertion. Runs against a
-- scratch buffer named as today's daily note (so quick_add doesn't try to
-- open/create the real one) under a throwaway root.

local bujo = require 'bujo'

local function today_buffer(lines, cursor_lnum)
    bujo.root = vim.fn.tempname()
    local now = os.date '*t'
    local path = string.format('%s/%04d/%02d/%04d-%02d-%02d.md', bujo.root, now.year, now.month, now.year, now.month, now.day)
    local buf = vim.api.nvim_create_buf(false, false)
    vim.api.nvim_buf_set_name(buf, path)
    vim.api.nvim_set_current_buf(buf)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_win_set_cursor(0, { cursor_lnum, 0 })
    return buf
end

local function buffer_lines(buf)
    return vim.api.nvim_buf_get_lines(buf, 0, -1, false)
end

describe('bujo.quick_add', function()
    after_each(function()
        vim.cmd.stopinsert()
    end)

    it('inserts the task below the cursor line, not at the end of the file', function()
        local buf = today_buffer({
            '# Thursday, 2026-07-16',
            '',
            '- [ ] first task',
            '- [ ] last task',
        }, 3)

        bujo.quick_add()

        assert.same({
            '# Thursday, 2026-07-16',
            '',
            '- [ ] first task',
            '- [ ] ',
            '- [ ] last task',
        }, buffer_lines(buf))
        assert.same({ 4, 6 }, vim.api.nvim_win_get_cursor(0))
    end)

    it('inherits the indentation of the cursor line', function()
        local buf = today_buffer({
            '- [ ] plan the offsite',
            '    - [x] book room',
            '- [ ] closing task',
        }, 2)

        bujo.quick_add()

        assert.same({
            '- [ ] plan the offsite',
            '    - [x] book room',
            '    - [ ] ',
            '- [ ] closing task',
        }, buffer_lines(buf))
        assert.same({ 3, 10 }, vim.api.nvim_win_get_cursor(0))
    end)

    it('fills a blank cursor line in place', function()
        local buf = today_buffer({
            '# Thursday, 2026-07-16',
            '',
            '- [ ] a task',
        }, 2)

        bujo.quick_add()

        assert.same({
            '# Thursday, 2026-07-16',
            '- [ ] ',
            '- [ ] a task',
        }, buffer_lines(buf))
        assert.same({ 2, 6 }, vim.api.nvim_win_get_cursor(0))
    end)
end)
