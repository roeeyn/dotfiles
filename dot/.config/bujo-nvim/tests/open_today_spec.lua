-- Specs for bujo.open_today's write ordering. migrate.lua is a pure
-- function, so migrate_spec.lua cannot see the order its two outputs get
-- committed to disk — that ordering is this file's whole subject. The
-- invariant: today's note must be durable before the source note is
-- rewritten with [>] marks, so an interrupted migration can only ever
-- duplicate tasks, never lose them.

local bujo = require 'bujo'

local function scratch_root()
    local root = vim.fn.tempname()
    bujo.root = root -- set directly; setup() would also install commands/keymaps
    vim.fn.mkdir(root .. '/2026/07', 'p')
    return root
end

local function today_path()
    local n = os.date '*t'
    return string.format('%s/%04d/%02d/%04d-%02d-%02d.md', bujo.root, n.year, n.month, n.year, n.month, n.day)
end

describe('bujo.open_today durability', function()
    local real_writefile

    before_each(function()
        real_writefile = vim.fn.writefile
    end)

    -- nil-ing the stub restores the builtin through vim.fn's __index
    after_each(function()
        vim.fn.writefile = nil
    end)

    it("writes today's note before releasing the source", function()
        local root = scratch_root()
        local prev = root .. '/2026/07/2026-07-31.md'
        real_writefile({ '# prev', '', '- [ ] pay the rent' }, prev)

        local order = {}
        vim.fn.writefile = function(lines, path)
            order[#order + 1] = path
            return real_writefile(lines, path)
        end

        bujo.open_today()

        assert.same({ today_path(), prev }, order)
    end)

    it('leaves the source untouched when the destination write fails', function()
        local root = scratch_root()
        local prev = root .. '/2026/07/2026-07-31.md'
        local original = { '# prev', '', '- [ ] pay the rent', '    - [ ] find the invoice' }
        real_writefile(original, prev)

        vim.fn.writefile = function(lines, path)
            if path == today_path() then
                error 'disk full'
            end
            return real_writefile(lines, path)
        end

        pcall(bujo.open_today)

        assert.same(original, vim.fn.readfile(prev))
    end)
end)
