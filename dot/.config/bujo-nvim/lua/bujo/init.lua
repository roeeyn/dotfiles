-- bujo — markdown daily notes with BuJo-style task migration.
--
-- Local module, not a published plugin: lives inside the bujo-nvim app
-- config and is wired up by a single require('bujo').setup() in init.lua.
-- The migration logic itself is the pure function in bujo/migrate.lua.

local migrate = require 'bujo.migrate'

local M = {}

-- e.g. 2026-07-11.md — filenames sort as dates, which the navigation and
-- "nearest previous note" logic relies on.
local DAILY_NAME = '^%d%d%d%d%-%d%d%-%d%d%.md$'

-- os.date('%A') is locale-dependent; the title weekday must always be English.
local WEEKDAYS = { 'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday' }

M.root = nil -- set in setup()

local function basename(path)
    return vim.fn.fnamemodify(path, ':t')
end

local function daily_path(y, m, d)
    return string.format('%s/%04d/%02d/%04d-%02d-%02d.md', M.root, y, m, y, m, d)
end

local function template_for(y, m, d)
    local t = os.time { year = y, month = m, day = d, hour = 12 }
    local weekday = WEEKDAYS[tonumber(os.date('%w', t)) + 1]
    return { string.format('# %s, %04d-%02d-%02d', weekday, y, m, d), '' }
end

-- All daily notes, ascending by date (== ascending by filename).
local function daily_notes()
    local files = vim.fn.glob(M.root .. '/[0-9][0-9][0-9][0-9]/[0-9][0-9]/*.md', true, true)
    local out = {}
    for _, f in ipairs(files) do
        if basename(f):match(DAILY_NAME) then
            out[#out + 1] = f
        end
    end
    table.sort(out)
    return out
end

local function edit(path, lnum)
    vim.cmd.edit(vim.fn.fnameescape(path))
    if lnum then
        vim.api.nvim_win_set_cursor(0, { math.min(lnum, vim.api.nvim_buf_line_count(0)), 0 })
    end
end

--- :BujoToday — open today's note, creating it (with migration from the
--- nearest previous daily note) only if it doesn't exist yet.
function M.open_today()
    local now = os.date '*t'
    local path = daily_path(now.year, now.month, now.day)

    if (vim.uv or vim.loop).fs_stat(path) then
        edit(path)
        return
    end

    local lines = template_for(now.year, now.month, now.day)

    -- Nearest previous existing note, not calendar-yesterday: weekends and
    -- vacations leave gaps, so walk the actual files.
    local previous
    local today_name = basename(path)
    for _, f in ipairs(daily_notes()) do
        if basename(f) < today_name then
            previous = f
        end
    end

    vim.fn.mkdir(vim.fn.fnamemodify(path, ':h'), 'p')

    -- Migration is a two-file transaction: today's note must be durable on
    -- disk BEFORE the source is rewritten with [>] marks. An interruption
    -- between the writes then duplicates tasks (visible, fixable) instead of
    -- losing them (silent: nothing lists [>], and the destination that never
    -- got written was the only other copy).
    local moved, rewritten
    if previous then
        moved, rewritten = migrate.migrate(vim.fn.readfile(previous))
        vim.list_extend(lines, moved)
    end

    vim.fn.writefile(lines, path)
    if moved and #moved > 0 then
        vim.fn.writefile(rewritten, previous)
    end

    edit(path, #lines)
end

--- :BujoPrev / :BujoNext — nearest existing daily note before/after the one
--- in the current buffer.
function M.goto_adjacent(direction)
    local current = basename(vim.api.nvim_buf_get_name(0))
    if not current:match(DAILY_NAME) then
        vim.notify('bujo: not in a daily note', vim.log.levels.WARN)
        return
    end

    local target
    for _, f in ipairs(daily_notes()) do
        local name = basename(f)
        if direction < 0 and name < current then
            target = f -- keeps the latest one below current
        elseif direction > 0 and name > current and not target then
            target = f -- first one above current
        end
    end

    if target then
        edit(target)
    else
        vim.notify('bujo: no ' .. (direction < 0 and 'previous' or 'next') .. ' daily note', vim.log.levels.WARN)
    end
end

--- Toggle `- [ ]` <-> `- [x]` on a line range. Other states (>, <, -) are
--- never touched: they are statements about the past, not toggles.
function M.toggle(line1, line2)
    for lnum = line1, line2 do
        local line = vim.fn.getline(lnum)
        local toggled
        if line:match '^%s*%- %[ %]' then
            toggled = line:gsub('^(%s*%- )%[ %]', '%1[x]', 1)
        elseif line:match '^%s*%- %[x%]' then
            toggled = line:gsub('^(%s*%- )%[x%]', '%1[ ]', 1)
        end
        if toggled then
            vim.fn.setline(lnum, toggled)
        end
    end
end

--- Quick-add: insert a fresh `- [ ]` below the cursor line, inheriting its
--- indentation (so adding from a subtask creates a sibling subtask), and
--- start typing. A blank cursor line is filled in place instead. Opens
--- today's note first if the buffer is somewhere else — the cursor then sits
--- on its last line, so the task lands at the end.
function M.quick_add()
    local now = os.date '*t'
    if vim.api.nvim_buf_get_name(0) ~= daily_path(now.year, now.month, now.day) then
        M.open_today()
    end

    local lnum = vim.api.nvim_win_get_cursor(0)[1]
    local line = vim.fn.getline(lnum)
    if line:match '^%s*$' then
        vim.api.nvim_buf_set_lines(0, lnum - 1, lnum, false, { '- [ ] ' })
    else
        vim.api.nvim_buf_set_lines(0, lnum, lnum, false, { line:match '^%s*' .. '- [ ] ' })
        lnum = lnum + 1
    end
    vim.api.nvim_win_set_cursor(0, { lnum, 0 })
    vim.cmd.startinsert { bang = true } -- like `A`: insert at end of line
end

--- :BujoNote <name> — named free-form note in ~/notes/notes/.
function M.open_named_note(name)
    -- Same slug rule bujo.links uses to resolve [[wikilinks]] back to files.
    local kebab = require('bujo.links').slug(name)
    if kebab == '' then
        vim.notify('bujo: cannot derive a filename from ' .. vim.inspect(name), vim.log.levels.ERROR)
        return
    end

    local path = M.root .. '/notes/' .. kebab .. '.md'
    if not (vim.uv or vim.loop).fs_stat(path) then
        vim.fn.mkdir(M.root .. '/notes', 'p')
        vim.fn.writefile({ '# ' .. name, '' }, path)
    end
    edit(path, 2)
end

--- :BujoNew — quick-capture an unnamed note: `YYYY-MM-DD Note <n>.md` with
--- an auto-incremented n. The filename is the stable id; the H1 placeholder
--- gets renamed once the note has a real subject.
function M.new_note()
    local date = os.date '%Y-%m-%d'
    local dir = M.root .. '/notes'
    vim.fn.mkdir(dir, 'p')

    local max = 0
    for _, f in ipairs(vim.fn.glob(dir .. '/' .. date .. ' Note *.md', true, true)) do
        local n = tonumber(basename(f):match '^%d%d%d%d%-%d%d%-%d%d Note (%d+)%.md$')
        if n and n > max then
            max = n
        end
    end

    local stem = string.format('%s Note %d', date, max + 1)
    local path = dir .. '/' .. stem .. '.md'
    vim.fn.writefile({ '# ' .. stem, '' }, path)
    edit(path, 2)
end

-- Telescope pickers ---------------------------------------------------------
-- telescope is lazy = true; lazy.nvim loads it on the first require below.

--- Daily notes list, newest first.
function M.pick_daily()
    local pickers = require 'telescope.pickers'
    local finders = require 'telescope.finders'
    local conf = require('telescope.config').values

    local files = daily_notes()
    local results = {}
    for i = #files, 1, -1 do
        results[#results + 1] = files[i]
    end

    pickers
        .new({}, {
            prompt_title = 'Daily notes',
            finder = finders.new_table {
                results = results,
                entry_maker = function(path)
                    local rel = path:sub(#M.root + 2)
                    return { value = path, display = rel, ordinal = rel, path = path, filename = path }
                end,
            },
            sorter = conf.generic_sorter {},
            previewer = conf.file_previewer {},
        })
        :find()
end

--- Live grep across all of ~/notes.
function M.grep_notes()
    require('telescope.builtin').live_grep { cwd = M.root, prompt_title = 'Grep notes' }
end

--- Pending `- [ ]` lines across the last ~30 days of daily notes, newest
--- first, jumping to the exact line on select.
function M.pick_tasks()
    local pickers = require 'telescope.pickers'
    local finders = require 'telescope.finders'
    local conf = require('telescope.config').values

    local cutoff = os.date('%Y-%m-%d', os.time() - 30 * 86400) .. '.md'
    -- Important tasks (`!` after the checkbox, see bujo/priority.lua) float
    -- to the top; both groups stay newest-file-first.
    local important, rest = {}, {}
    local files = daily_notes()
    for i = #files, 1, -1 do -- newest file first
        local f = files[i]
        if basename(f) >= cutoff then
            for lnum, line in ipairs(vim.fn.readfile(f)) do
                if line:match '^%s*%- %[ %]' then
                    local bucket = line:match '^%s*%- %[ %] !' and important or rest
                    bucket[#bucket + 1] = { path = f, lnum = lnum, text = line }
                end
            end
        end
    end
    local results = vim.list_extend(important, rest)

    pickers
        .new({}, {
            prompt_title = 'Pending tasks (last 30 days)',
            finder = finders.new_table {
                results = results,
                entry_maker = function(item)
                    local date = basename(item.path):sub(1, 10)
                    local task = item.text:gsub('^%s*%- %[ %] ?', '')
                    local display = date .. '  ' .. task
                    return {
                        value = item,
                        display = display,
                        ordinal = display,
                        path = item.path,
                        filename = item.path,
                        lnum = item.lnum,
                    }
                end,
            },
            sorter = conf.generic_sorter {},
            previewer = conf.grep_previewer {},
        })
        :find()
end

-- Setup ----------------------------------------------------------------------

local function complete_named_notes()
    local out = {}
    for _, f in ipairs(vim.fn.glob(M.root .. '/notes/*.md', true, true)) do
        out[#out + 1] = vim.fn.fnamemodify(f, ':t:r')
    end
    return out
end

function M.setup(opts)
    M.root = vim.fs.normalize((opts and opts.root) or vim.env.BUJO_NOTES_DIR or '~/notes')
    -- links needs the root to resolve [[wikilinks]] to files; explicit opts win.
    require('bujo.links').setup(vim.tbl_extend('keep', opts and opts.links or {}, { root = M.root }))
    require('bujo.strike').setup(opts and opts.strike)
    require('bujo.priority').setup(opts and opts.priority)
    require('bujo.fold').setup(opts and opts.fold)
    -- mention needs the root to list picker candidates; explicit opts win.
    require('bujo.mention').setup(vim.tbl_extend('keep', opts and opts.mention or {}, { root = M.root }))

    local command = vim.api.nvim_create_user_command
    command('BujoToday', M.open_today, { desc = "Open (or create + migrate) today's daily note" })
    command('BujoPrev', function()
        M.goto_adjacent(-1)
    end, { desc = 'Jump to the nearest previous daily note' })
    command('BujoNext', function()
        M.goto_adjacent(1)
    end, { desc = 'Jump to the nearest next daily note' })
    command('BujoNote', function(o)
        M.open_named_note(o.args)
    end, { nargs = '+', complete = complete_named_notes, desc = 'Create/open a named note in notes/' })
    command('BujoNew', M.new_note, { desc = 'Quick-capture a new unnamed note' })
    command('BujoToggle', function(o)
        M.toggle(o.line1, o.line2)
    end, { range = true, desc = 'Toggle - [ ] <-> - [x] on the line/range' })

    local map = vim.keymap.set
    map('n', '<leader>d', '<cmd>BujoToday<cr>', { desc = "Today's daily note" })
    map('n', '<leader>h', '<cmd>BujoPrev<cr>', { desc = 'Previous daily note (back in time)' })
    map('n', '<leader>l', '<cmd>BujoNext<cr>', { desc = 'Next daily note (forward in time)' })
    -- `:` not `<cmd>` so visual mode passes its range to the command
    map({ 'n', 'x' }, '<leader>x', ':BujoToggle<cr>', { silent = true, desc = 'Toggle checkbox' })
    -- alias matching the comment-line binding in the main nvim config
    map({ 'n', 'x' }, '<leader>;l', ':BujoToggle<cr>', { silent = true, desc = 'Toggle checkbox' })
    map('n', '<leader>a', M.quick_add, { desc = "Add a task to today's note" })
    map('n', '<leader>nn', M.new_note, { desc = 'New quick-capture note' })
    map('n', '<leader>fd', M.pick_daily, { desc = 'Find daily note' })
    map('n', '<leader>fg', M.grep_notes, { desc = 'Grep all notes' })
    map('n', '<leader>ft', M.pick_tasks, { desc = 'Find pending tasks (30 days)' })

    -- Prefill: entering an *empty* buffer whose path looks like a daily note
    -- (YYYY/MM/YYYY-MM-DD.md) inserts the template for that file's date —
    -- e.g. when back-filling a missed day by hand.
    local group = vim.api.nvim_create_augroup('bujo', { clear = true })
    vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufReadPost' }, {
        group = group,
        pattern = '*.md',
        callback = function(args)
            local path = vim.api.nvim_buf_get_name(args.buf)
            local dy, dm, y, m, d = path:match '(%d%d%d%d)/(%d%d)/(%d%d%d%d)%-(%d%d)%-(%d%d)%.md$'
            if not dy or dy ~= y or dm ~= m then
                return
            end
            if vim.api.nvim_buf_line_count(args.buf) > 1 or vim.api.nvim_buf_get_lines(args.buf, 0, 1, false)[1] ~= '' then
                return
            end
            vim.api.nvim_buf_set_lines(args.buf, 0, -1, false, template_for(tonumber(y), tonumber(m), tonumber(d)))
        end,
    })
end

return M
