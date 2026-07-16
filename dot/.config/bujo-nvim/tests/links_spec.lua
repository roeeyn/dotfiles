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

        it('routes Bitbucket-hosted repos to Bitbucket', function()
            assert.equal('https://bitbucket.org/alertmediaadmin/notify_me/pull-requests/6366', links.resolve 'notify_me#6366')
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

        it('ignores refs inside markdown links and bare URLs', function()
            local line = 'see [nr#52](https://github.com/alertmediainc/notification_router/pull/52) and https://x.test/MSG-1'
            assert.same({}, links.refs(line))
        end)

        it('does not treat headings or dates as refs', function()
            assert.same({}, links.refs '# Thursday, 2026-07-16')
        end)

        it('classifies kinds for decoration', function()
            local refs = links.refs 'MSG-1 nr#2 notify_me#3'
            assert.same({ 'jira', 'github', 'bitbucket' }, { refs[1].kind, refs[2].kind, refs[3].kind })
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
