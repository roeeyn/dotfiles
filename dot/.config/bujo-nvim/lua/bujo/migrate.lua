-- bujo.migrate — the BuJo migration logic as a pure function. No editor
-- state, no filesystem: lines in, lines out. Tested by tests/migrate_spec.lua.
--
-- Semantics (see README):
--   * A migration root is any line whose first non-whitespace content is
--     `- [ ]` and that is not already inside another root's block.
--   * A root's block is the root plus all subsequent lines with strictly
--     deeper indentation — nested tasks of any state, `- ` note bullets,
--     free text. A blank line ends the block.
--   * Blocks are copied into today in source order. Every copied `- [ ]`
--     (root or child) becomes `- [>]` in the source; nothing is deleted and
--     non-task lines are left untouched, so the previous day stays a
--     truthful record.
--   * Roots are emitted with the root at column 0, children keeping their
--     relative indentation. Top-level roots are therefore copied verbatim;
--     an indented root (e.g. a pending child under a `- [x]` parent, which
--     must still migrate) is dedented into a top-level task of its own.
--
-- Indentation is measured in leading whitespace characters; notes are
-- written with expandtab, so tabs never mix with spaces in practice.

local M = {}

local function indent_width(line)
    return #line:match '^[ \t]*'
end

local function is_blank(line)
    return line:match '^%s*$' ~= nil
end

-- Pending task: first non-whitespace content is `- [ ]`.
local function is_pending(line)
    return line:match '^%s*%- %[ %]' ~= nil
end

local function mark_migrated(line)
    return (line:gsub('^(%s*%- )%[ %]', '%1[>]', 1))
end

--- Migrate pending tasks out of a previous daily note.
--- @param lines string[] the previous note, as-is
--- @return string[] today_lines blocks to append under today's title
--- @return string[] source_lines the previous note rewritten with `[>]` marks
function M.migrate(lines)
    local today, source = {}, {}
    for i, line in ipairs(lines) do
        source[i] = line
    end

    local i, n = 1, #lines
    while i <= n do
        local line = lines[i]
        if is_pending(line) then
            local root_indent = indent_width(line)

            local last = i
            while last < n and not is_blank(lines[last + 1]) and indent_width(lines[last + 1]) > root_indent do
                last = last + 1
            end

            for k = i, last do
                local raw = lines[k]
                if is_pending(raw) then
                    source[k] = mark_migrated(raw)
                end
                -- root to column 0, children keep relative indentation
                today[#today + 1] = raw:sub(root_indent + 1)
            end

            i = last + 1
        else
            i = i + 1
        end
    end

    return today, source
end

return M
