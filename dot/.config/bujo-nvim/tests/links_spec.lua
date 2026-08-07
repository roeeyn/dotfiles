-- Specs for bujo.links — ref parsing, URL reconstruction, and link
-- shortening. All pure functions; nothing here touches buffers.

local links = require 'bujo.links'

describe('bujo.links', function()
    describe('resolve', function()
        it('builds Jira URLs from ticket refs', function()
            assert.equal('https://alertmedia.atlassian.net/browse/MSG-3111', links.resolve 'MSG-3111')
        end)

        it('builds GitHub URLs, expanding aliases', function()
            assert.equal('https://github.com/alertmediainc/notification_router/issues/52', links.resolve 'nr#52')
            assert.equal('https://github.com/alertmediainc/messaging_stats_service/issues/69', links.resolve 'mss#69')
            assert.equal('https://github.com/alertmediainc/src-root/issues/32', links.resolve 'src-root#32')
        end)

        it('routes notify_me to GitHub since the 2026-07-27 migration', function()
            assert.equal('https://github.com/alertmediainc/notify_me/issues/6366', links.resolve 'notify_me#6366')
        end)

        it('passes bare URLs through verbatim', function()
            assert.equal('https://example.com/docs?q=1', links.resolve 'https://example.com/docs?q=1')
        end)

        it('rejects non-refs', function()
            assert.is_nil(links.resolve 'plain word')
            assert.is_nil(links.resolve '2026-07-16')
        end)
    end)

    describe('refs / find', function()
        it('finds refs surrounded by punctuation', function()
            local line = '- [ ] Review nr#52 (MSG-3226, Python 3.14 upgrade)'
            assert.equal('https://github.com/alertmediainc/notification_router/issues/52', links.find(line, 14))
            assert.equal('https://alertmedia.atlassian.net/browse/MSG-3226', links.find(line, 21))
            assert.is_nil(links.find(line, 7)) -- on 'Review'
        end)

        it('masks markdown links; bare URLs become url refs, not ticket refs', function()
            local line = 'see [nr#52](https://github.com/alertmediainc/notification_router/pull/52) and https://x.test/MSG-1'
            local from = line:find('https://x.test', 1, true)
            local refs = links.refs(line)
            assert.same({ { ref = 'https://x.test/MSG-1', kind = 'url', from = from, to = #line } }, refs)
        end)

        it('opens a bare URL under the cursor', function()
            local line = '- [ ] read https://example.com/docs then MSG-9'
            assert.equal('https://example.com/docs', links.find(line, 12))
            assert.equal('https://alertmedia.atlassian.net/browse/MSG-9', links.find(line, 42))
        end)

        it('leaves <autolinks> to render-markdown', function()
            assert.same({}, links.refs 'auto <https://x.test> done')
        end)

        -- Balanced-paren trimming: keep a trailing `)` only when the URL
        -- contains an unmatched `(` (wikipedia-style paths).
        it('trims trailing prose punctuation off bare URLs', function()
            assert.equal('https://x.test', links.refs('see https://x.test.')[1].ref)
            assert.equal('https://x.test', links.refs('(see https://x.test)')[1].ref)
            assert.equal('https://x.test', links.refs('really? https://x.test),')[1].ref)
            assert.equal('https://en.wikipedia.org/wiki/Foo_(bar)', links.refs('read https://en.wikipedia.org/wiki/Foo_(bar) today')[1].ref)
            assert.equal('https://en.wikipedia.org/wiki/Foo_(bar)', links.refs('(read https://en.wikipedia.org/wiki/Foo_(bar))')[1].ref)
        end)

        it('does not treat headings or dates as refs', function()
            assert.same({}, links.refs '# Thursday, 2026-07-16')
        end)

        it('classifies kinds for decoration', function()
            local refs = links.refs 'MSG-1 nr#2 notify_me#3'
            assert.same({ 'jira', 'github', 'github' }, { refs[1].kind, refs[2].kind, refs[3].kind })
        end)
    end)

    describe('wikilinks', function()
        it('spans the brackets so gx fires anywhere on the link', function()
            local line = '    - research done → [[elixir-broadway-tips]] (backpressure notes)'
            local from = line:find('[[', 1, true)
            assert.same({
                { ref = 'elixir-broadway-tips', kind = 'note', from = from, to = from + #'[[elixir-broadway-tips]]' - 1 },
            }, links.refs(line))
        end)

        it('takes the destination half of [[dest|alias]]', function()
            assert.equal('Load Testing Guide', links.refs('see [[Load Testing Guide|the guide]] first')[1].ref)
        end)

        it('keeps titles with spaces and parens intact', function()
            assert.equal('Remote Envs (Manual in ECS)', links.refs('look [[Remote Envs (Manual in ECS)]]')[1].ref)
        end)

        -- The vault's how-to notes embed shell scripts; `[[` is a bash keyword
        -- and so always carries a space after it. Padding is the discriminator.
        it('ignores bash test expressions', function()
            assert.same({}, links.refs 'if [[ -n "$prefix" ]]; then')
            assert.same({}, links.refs 'while [[ $# -gt 0 ]]; do')
            assert.same({}, links.refs '[[ -z "$bearer_token" && -n "${TOKEN:-}" ]] && exit 1')
        end)

        it('does not leak refs out of a bash test into ticket parsing', function()
            assert.same({}, links.refs 'if [[ "$x" == "MSG-1" ]]; then')
        end)

        it('shields a wikilinked title from the ticket passes', function()
            local refs = links.refs 'see [[MSG-3111 postmortem]] and MSG-3226'
            assert.same({ 'note', 'jira' }, { refs[1].kind, refs[2].kind })
            assert.equal('MSG-3111 postmortem', refs[1].ref)
            assert.equal('MSG-3226', refs[2].ref)
        end)
    end)

    describe('slug', function()
        it('matches the filenames :BujoNote creates', function()
            assert.equal('broadway-101-elixir-pipelines', links.slug 'Broadway 101 Elixir Pipelines')
            assert.equal('remote-envs-manual-in-ecs', links.slug 'Remote Envs (Manual in ECS)')
            assert.equal('', links.slug '(!!)')
        end)
    end)

    describe('note_path', function()
        local root, saved

        local function write(rel)
            local path = root .. '/' .. rel
            vim.fn.mkdir(vim.fn.fnamemodify(path, ':h'), 'p')
            vim.fn.writefile({ '# note' }, path)
            return path
        end

        before_each(function()
            root = vim.fn.tempname()
            saved = links.config.root
            links.config.root = root
        end)

        after_each(function()
            links.config.root = saved
            vim.fn.delete(root, 'rf')
        end)

        it('prefers the verbatim title', function()
            local path = write 'notes/Load Testing Guide.md'
            assert.equal(path, links.note_path 'Load Testing Guide')
        end)

        it('falls back to the kebab stem', function()
            local path = write 'notes/elixir-broadway-tips.md'
            assert.equal(path, links.note_path 'elixir-broadway-tips')
            assert.equal(path, links.note_path 'Elixir Broadway Tips')
        end)

        it('matches case-insensitively as a last resort', function()
            local path = write 'notes/Broadway 101 Elixir Pipelines.md'
            assert.equal(path, links.note_path 'broadway 101 elixir pipelines')
        end)

        it('resolves a date to its daily note, not notes/', function()
            local path = write '2026/08/2026-08-05.md'
            assert.equal(path, links.note_path '2026-08-05')
        end)

        it('returns nil for a dangling link instead of inventing a file', function()
            write 'notes/Load Testing Guide.md'
            assert.is_nil(links.note_path 'Remote Envs (Manual in ECS)')
            assert.equal(0, vim.fn.filereadable(root .. '/notes/Remote Envs (Manual in ECS).md'))
        end)
    end)

    describe('find', function()
        it('returns a path and the note kind for wikilinks', function()
            local root = vim.fn.tempname()
            local saved = links.config.root
            links.config.root = root
            vim.fn.mkdir(root .. '/notes', 'p')
            vim.fn.writefile({ '# g' }, root .. '/notes/Load Testing Guide.md')

            local line = 'batch first, see [[Load Testing Guide]] before running'
            local target, kind = links.find(line, line:find('Load Testing', 1, true))
            assert.equal(root .. '/notes/Load Testing Guide.md', target)
            assert.equal('note', kind)

            links.config.root = saved
            vim.fn.delete(root, 'rf')
        end)

        it('still reports the kind alongside URLs', function()
            local _, kind = links.find('- [ ] Review nr#52', 14)
            assert.equal('github', kind)
        end)
    end)

    describe('url_to_ref', function()
        it('prefers aliases and tolerates URL tails', function()
            assert.equal('nr#52', links.url_to_ref 'https://github.com/alertmediainc/notification_router/pull/52')
            assert.equal('notify_me#6366', links.url_to_ref 'https://bitbucket.org/alertmediaadmin/notify_me/pull-requests/6366/overview')
            assert.equal('MSG-3111', links.url_to_ref 'https://alertmedia.atlassian.net/browse/MSG-3111')
        end)

        it('returns nil for foreign or non-PR URLs', function()
            assert.is_nil(links.url_to_ref 'https://github.com/alertmediainc/nr/releases/5')
            assert.is_nil(links.url_to_ref 'https://example.com/MSG-1')
        end)
    end)

    describe('shorten', function()
        it('unwraps ref-labeled links, counting them', function()
            local out, n = links.shorten {
                '- [ ] Review the spec for [MSG-3111](https://alertmedia.atlassian.net/browse/MSG-3111) (quicksend)',
                '- [ ] Merge [src-root#32](https://github.com/alertmediainc/src-root/pull/32) and [nr#52](https://github.com/alertmediainc/notification_router/pull/52)',
            }
            assert.same({
                '- [ ] Review the spec for MSG-3111 (quicksend)',
                '- [ ] Merge src-root#32 and nr#52',
            }, out)
            assert.equal(3, n)
        end)

        it('keeps prose labels and foreign URLs untouched', function()
            local out, n = links.shorten {
                '- [ ] read [the router PR](https://github.com/alertmediainc/notification_router/pull/52)',
                '- [ ] see [docs](https://example.com/docs) and checkbox - [x] stays',
            }
            assert.same({
                '- [ ] read [the router PR](https://github.com/alertmediainc/notification_router/pull/52)',
                '- [ ] see [docs](https://example.com/docs) and checkbox - [x] stays',
            }, out)
            assert.equal(0, n)
        end)

        it('accepts an alias label for the full repo URL and vice versa', function()
            local out, n = links.shorten {
                '[notification_router#52](https://github.com/alertmediainc/notification_router/pull/52)',
                '[tf-modules#205](https://github.com/alertmediainc/terraform-modules/pull/205)',
            }
            assert.same({ 'notification_router#52', 'tf-modules#205' }, out)
            assert.equal(2, n)
        end)
    end)
end)
