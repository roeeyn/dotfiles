local source = {}

source.new = function()
    local self = setmetatable({}, { __index = source })
    self._cache = nil
    self._cache_cwd = nil
    return self
end

source.get_keyword_pattern = function()
    return [[@\S*]]
end

source.get_trigger_characters = function()
    return { '@' }
end

source.is_available = function()
    return vim.fn.executable 'fd' == 1
end

function source:_get_cwd()
    local cwd = vim.env.SLIM_NVIM_CWD
    if cwd and cwd ~= '' then
        return cwd
    end
    return vim.fn.getcwd()
end

function source:_get_files(cwd, callback)
    if self._cache and self._cache_cwd == cwd then
        callback(self._cache)
        return
    end

    vim.fn.jobstart({ 'fd', '--type', 'f', '--hidden', '--exclude', '.git', '--strip-cwd-prefix' }, {
        cwd = cwd,
        stdout_buffered = true,
        on_stdout = function(_, data)
            local files = {}
            for _, line in ipairs(data) do
                if line ~= '' then
                    table.insert(files, line)
                end
            end
            self._cache = files
            self._cache_cwd = cwd
            callback(files)
        end,
    })
end

function source:complete(params, callback)
    local input = params.context.cursor_before_line
    local at_match = input:match '@([^%s]*)$'

    if at_match == nil then
        callback()
        return
    end

    local cwd = self:_get_cwd()

    self:_get_files(cwd, function(files)
        local items = {}
        for _, file in ipairs(files) do
            local basename = file:match '[^/]+$' or file
            table.insert(items, {
                label = '@' .. file,
                insertText = '@' .. file,
                filterText = '@' .. file .. ' @' .. basename,
                sortText = file,
                kind = vim.lsp.protocol.CompletionItemKind.File,
            })
        end
        callback(items)
    end)
end

return source
