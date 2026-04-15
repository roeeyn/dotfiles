-- Claude skills completion source for nvim-cmp.
-- Triggers on / and offers Claude Code skill names as completions.
-- Requires `claude` CLI to be available.

local source = {}

-- Cache for 10 minutes — skills rarely change within a session
local CACHE_TTL = 600

source.new = function()
    return setmetatable({ _cache = nil, _cache_time = 0 }, { __index = source })
end

-- Standard Vim regex (not \v magic) — required by nvim-cmp's vim.regex() call
source.get_keyword_pattern = function()
    return [[\/[a-zA-Z0-9_:-]*]]
end

source.get_trigger_characters = function()
    return { '/' }
end

source.is_available = function()
    return vim.fn.executable 'claude' == 1
end

function source:complete(params, callback)
    local before = params.context.cursor_before_line
    local skill_prefix = before:match '(/%S*)$'
    if not skill_prefix then
        callback()
        return
    end

    -- Only trigger when / is at start of line or preceded by whitespace (not a path)
    local prefix_pos = #before - #skill_prefix
    if prefix_pos > 0 and not before:sub(prefix_pos, prefix_pos):match '%s' then
        callback()
        return
    end

    if self._cache and (vim.uv.now() / 1000 - self._cache_time) < CACHE_TTL then
        callback(self._cache)
        return
    end

    vim.fn.jobstart({ 'claude', 'skills' }, {
        stdout_buffered = true,
        on_stdout = function(_, data)
            local items = {}
            local output = table.concat(data, '\n')

            -- Parse skill names from table output: | `/skill-name` | description |
            for name, desc in output:gmatch '|%s*`(/[^`]+)`%s*|%s*([^|]+)|' do
                local trimmed_desc = desc:match '^%s*(.-)%s*$' or desc
                table.insert(items, {
                    label = name,
                    insertText = name,
                    detail = trimmed_desc,
                    kind = vim.lsp.protocol.CompletionItemKind.Function,
                })
            end

            self._cache = items
            self._cache_time = vim.uv.now() / 1000
            callback(items)
        end,
    })
end

return source
