-- bujo.mention — @-triggered note picker that inserts [[wikilinks]].
--
-- Typing `@` in insert mode opens a Telescope picker over the vault's notes;
-- choosing one inserts `[[stem]]` at the cursor (the `@` itself is never
-- written) and resumes typing right after the closing brackets. gx then opens
-- the link via bujo.links.note_path, whose first ladder rung resolves on-disk
-- stems verbatim — so the inserted stem always round-trips.
--
-- Cancelling the picker (<Esc>) inserts nothing: the guard in should_trigger
-- decides when `@` stays literal text, not the cancel path.

local M = {}

M.config = {
    -- bujo.setup() overrides this with its own root; the default only matters
    -- when mention.lua is required directly (specs).
    root = vim.fs.normalize(vim.env.BUJO_NOTES_DIR or '~/notes'),
}

-- First `# H1` line of a file, or nil.
local function h1(path)
    local first = vim.fn.readfile(path, '', 1)[1]
    return first and first:match '^#%s+(.-)%s*$'
end

--- Picker candidates: named notes first (most recently modified at the top,
--- since a just-captured idea is the likeliest link target), then daily notes
--- newest first. Quick-capture filenames are opaque (`2026-08-17 Note 3`), so
--- the display leads with the H1 title; `stem` is always the on-disk filename
--- stem — the one form note_path resolves without guessing.
function M.candidates()
    local root = M.config.root

    local named = {}
    for _, f in ipairs(vim.fn.glob(root .. '/notes/*.md', true, true)) do
        local stem = vim.fn.fnamemodify(f, ':t:r')
        local title = h1(f)
        named[#named + 1] = {
            stem = stem,
            path = f,
            mtime = vim.fn.getftime(f),
            display = (title and title ~= stem) and (title .. '  ·  ' .. stem) or stem,
        }
    end
    table.sort(named, function(a, b)
        return a.mtime > b.mtime
    end)

    local dailies = {}
    for _, f in ipairs(vim.fn.glob(root .. '/[0-9][0-9][0-9][0-9]/[0-9][0-9]/*.md', true, true)) do
        local stem = vim.fn.fnamemodify(f, ':t:r')
        if stem:match '^%d%d%d%d%-%d%d%-%d%d$' then
            dailies[#dailies + 1] = { stem = stem, path = f, display = stem }
        end
    end
    table.sort(dailies, function(a, b)
        return a.stem > b.stem
    end)

    return vim.list_extend(named, dailies)
end

--- Whether an `@` typed here should open the picker (true) or stay literal
--- text (false). `line` is the current line; `col` is the 0-based count of
--- bytes before the cursor, so line:sub(col, col) is the character the `@`
--- would follow ('' at the start of the line).
---
--- Policy: fire at the start of a line or after whitespace/`(`, stay literal
--- everywhere else. Emails always carry a word character before the `@`, so
--- they never trigger; a multibyte character before the cursor yields a
--- non-matching trailing byte and stays literal too — the conservative side.
function M.should_trigger(line, col)
    if col == 0 then
        return true
    end
    return line:sub(col, col):match '[%s(]' ~= nil
end

--- Insert `text` at the position captured when `@` was typed and resume
--- typing right after it. `col` is the 0-based byte offset from insert mode,
--- which IS the byte insertion point. The cursor is parked on the last
--- inserted byte and `a` re-enters insert — that lands after the text at EOL
--- and mid-line alike (startinsert can't place the cursor past the last
--- character, so it would need an EOL branch).
function M.insert_link(buf, row, col, text)
    vim.api.nvim_buf_set_text(buf, row - 1, col, row - 1, col, { text })
    vim.api.nvim_win_set_cursor(0, { row, col + #text - 1 })
    vim.api.nvim_feedkeys('a', 'n', false)
end

--- Open the picker for the position captured by the `@` mapping.
function M.pick(buf, row, col)
    local pickers = require 'telescope.pickers'
    local finders = require 'telescope.finders'
    local conf = require('telescope.config').values
    local actions = require 'telescope.actions'
    local action_state = require 'telescope.actions.state'

    pickers
        .new({}, {
            prompt_title = 'Link note',
            finder = finders.new_table {
                results = M.candidates(),
                entry_maker = function(item)
                    return { value = item, display = item.display, ordinal = item.display, path = item.path, filename = item.path }
                end,
            },
            sorter = conf.generic_sorter {},
            previewer = conf.file_previewer {},
            attach_mappings = function(prompt_bufnr)
                actions.select_default:replace(function()
                    local entry = action_state.get_selected_entry()
                    actions.close(prompt_bufnr)
                    if entry then
                        -- Scheduled so the insert runs after telescope has
                        -- fully torn down and restored the original window.
                        vim.schedule(function()
                            M.insert_link(buf, row, col, '[[' .. entry.value.stem .. ']]')
                        end)
                    end
                end)
                return true
            end,
        })
        :find()
end

local function on_at()
    local pos = vim.api.nvim_win_get_cursor(0)
    local row, col = pos[1], pos[2]
    if not M.should_trigger(vim.api.nvim_get_current_line(), col) then
        return '@'
    end
    local buf = vim.api.nvim_get_current_buf()
    -- expr mappings run under textlock: reading state is fine, opening a
    -- window is not — defer the picker and swallow the `@`.
    vim.schedule(function()
        M.pick(buf, row, col)
    end)
    return ''
end

function M.setup(opts)
    M.config = vim.tbl_deep_extend('force', M.config, opts or {})

    local group = vim.api.nvim_create_augroup('bujo-mention', { clear = true })
    vim.api.nvim_create_autocmd('FileType', {
        group = group,
        pattern = 'markdown',
        callback = function(a)
            vim.keymap.set('i', '@', on_at, { buffer = a.buf, expr = true, desc = 'Pick a note to insert as [[wikilink]]' })
        end,
    })
end

return M
