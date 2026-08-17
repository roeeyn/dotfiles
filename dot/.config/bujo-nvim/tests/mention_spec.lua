-- Specs for bujo.mention — candidate building is pure given a fixture vault.
-- The insert-mode mapping itself can't run headlessly (see CLAUDE.md: you
-- cannot genuinely enter Insert mode inside a spec), so the trigger guard is
-- specced as a plain function on (line, col).

local mention = require 'bujo.mention'

local function write(path, lines, mtime)
    vim.fn.mkdir(vim.fn.fnamemodify(path, ':h'), 'p')
    vim.fn.writefile(lines, path)
    if mtime then
        (vim.uv or vim.loop).fs_utime(path, mtime, mtime)
    end
end

describe('bujo.mention', function()
    local root

    before_each(function()
        root = vim.fn.tempname()
        -- Named notes with controlled mtimes: the idea captured last must
        -- surface first. One opaque quick-capture name, one title == stem.
        write(root .. '/notes/Load Testing Guide.md', { '# Load Testing Guide', '' }, 1000)
        write(root .. '/notes/2026-08-17 Note 1.md', { '# Broadway backpressure idea', '' }, 2000)
        write(root .. '/2026/08/2026-08-16.md', { '# Sunday, 2026-08-16' })
        write(root .. '/2026/08/2026-08-17.md', { '# Monday, 2026-08-17' })
        mention.config.root = root
    end)

    describe('candidates', function()
        it('lists named notes by recency, then dailies newest first', function()
            local stems = vim.tbl_map(function(c)
                return c.stem
            end, mention.candidates())
            assert.same({ '2026-08-17 Note 1', 'Load Testing Guide', '2026-08-17', '2026-08-16' }, stems)
        end)

        it('leads with the H1 title when the filename is opaque', function()
            assert.equal('Broadway backpressure idea  ·  2026-08-17 Note 1', mention.candidates()[1].display)
        end)

        it('shows just the stem when the title matches it', function()
            assert.equal('Load Testing Guide', mention.candidates()[2].display)
        end)

        it('keeps the on-disk stem as the link target so note_path resolves it', function()
            local links = require 'bujo.links'
            links.config.root = root
            for _, c in ipairs(mention.candidates()) do
                assert.equal(c.path, links.note_path(c.stem))
            end
        end)
    end)

    describe('should_trigger', function()
        it('fires at the start of a line', function()
            assert.is_true(mention.should_trigger('', 0))
            assert.is_true(mention.should_trigger('anything after the cursor', 0))
        end)

        it('fires after whitespace or an opening paren', function()
            assert.is_true(mention.should_trigger('- [ ] see ', 10))
            assert.is_true(mention.should_trigger('- [ ] idea (', 12))
        end)

        it('stays literal right after a word character (emails)', function()
            assert.is_false(mention.should_trigger('mail rodrigo.medina', 19))
            assert.is_false(mention.should_trigger('foo@', 3))
        end)

        it('stays literal after punctuation that glues to a word', function()
            assert.is_false(mention.should_trigger('see notes/', 10))
            assert.is_false(mention.should_trigger('a "quoted', 9))
        end)
    end)
end)
