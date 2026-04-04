-- Jira completion source for nvim-cmp.
-- Triggers on [A-Z]+- patterns (e.g. "MSG-"), fetches active project issues
-- via Jira REST API v3, and inserts markdown links on selection.
-- Requires ATLASSIAN_URL, ATLASSIAN_USERNAME, ATLASSIAN_API_KEY env vars.

local source = {}

-- Cache results for 5 minutes to avoid repeated API calls while typing
local CACHE_TTL = 300

source.new = function()
    return setmetatable({ _cache = nil, _cache_time = 0, _cache_project = nil }, { __index = source })
end

-- Standard Vim regex (not \v magic) — required by nvim-cmp's vim.regex() call
source.get_keyword_pattern = function()
    return [[\%([A-Z]\+\-\d*\)]]
end

source.get_trigger_characters = function()
    return { '-' }
end

source.is_available = function()
    return vim.fn.executable 'curl' == 1 and vim.env.ATLASSIAN_URL ~= nil and vim.env.ATLASSIAN_USERNAME ~= nil and vim.env.ATLASSIAN_API_KEY ~= nil
end

local function url_encode(str)
    return str:gsub('([^%w%-_.~])', function(c)
        return string.format('%%%02X', string.byte(c))
    end)
end

function source:complete(params, callback)
    local project = params.context.cursor_before_line:match '([A-Z]+)%-[%d]*$'
    if not project then
        callback()
        return
    end

    if self._cache and self._cache_project == project and (vim.uv.now() / 1000 - self._cache_time) < CACHE_TTL then
        callback(self._cache)
        return
    end

    local url = vim.env.ATLASSIAN_URL
    -- Fetch all non-closed issues, not just assigned to current user,
    -- so teammates' tickets (e.g. ones you're testing) also appear
    local jql = string.format('project = "%s" AND status NOT IN (Done, Closed) ORDER BY updated DESC', project)
    local api_url = string.format('%s/rest/api/3/search/jql?jql=%s&fields=summary,status&maxResults=100', url, url_encode(jql))

    vim.fn.jobstart({
        'curl',
        '-s',
        '-u',
        vim.env.ATLASSIAN_USERNAME .. ':' .. vim.env.ATLASSIAN_API_KEY,
        '-H',
        'Content-Type: application/json',
        api_url,
    }, {
        stdout_buffered = true,
        on_stdout = function(_, data)
            local ok, parsed = pcall(vim.json.decode, table.concat(data, ''))
            if not ok or not parsed or not parsed.issues then
                callback {}
                return
            end

            local items = {}
            for _, issue in ipairs(parsed.issues) do
                local key = issue.key or ''
                local summary = (issue.fields and issue.fields.summary) or ''
                local status = (issue.fields and issue.fields.status and issue.fields.status.name) or ''

                table.insert(items, {
                    label = key,
                    detail = summary,
                    documentation = string.format('[%s] %s\n%s/browse/%s', status, summary, url, key),
                    insertText = string.format('[%s: %s](%s/browse/%s)', key, summary, url, key),
                    filterText = key .. ' ' .. summary,
                    sortText = key,
                    kind = vim.lsp.protocol.CompletionItemKind.Reference,
                })
            end

            self._cache = items
            self._cache_time = vim.uv.now() / 1000
            self._cache_project = project
            callback(items)
        end,
    })
end

return source
