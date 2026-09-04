-- Specs for bujo.review — turning a task line into a launch plan. Pure;
-- nothing here spawns a tab or touches a buffer.

local review = require 'bujo.review'

describe('bujo.review', function()
    describe('plan', function()
        it('pulls the PR url and ticket out of a review task line', function()
            local p = assert(review.plan '- [ ] Review template-view coverage am#70 (MSG-3416)')
            assert.equal('https://github.com/alertmediainc/automate_me/pull/70', p.url)
            assert.equal('MSG-3416', p.ticket)
            assert.equal('CR: MSG-3416', p.tab_name)
        end)

        -- links.resolve emits /issues/N (GitHub redirects it); the review skill
        -- parses the URL itself, so it must get the real /pull/ form.
        it('rewrites /issues/ to /pull/', function()
            local p = assert(review.plan '- [ ] Re-review nr#75 (MSG-3328)')
            assert.equal('https://github.com/alertmediainc/notification_router/pull/75', p.url)
        end)

        it('falls back to the PR ref when the line has no ticket', function()
            local p = assert(review.plan '- [ ] Review the gitignore change outbox#63')
            assert.equal('CR: outbox#63', p.tab_name)
            assert.is_nil(p.ticket)
        end)

        it('takes the first PR ref when a line mentions several', function()
            local p = assert(review.plan '- [ ] Review nr#78 and its twin nr#75 (MSG-3447)')
            assert.equal('https://github.com/alertmediainc/notification_router/pull/78', p.url)
            assert.equal('CR: MSG-3447', p.tab_name)
        end)

        it('refuses a line with no PR reference', function()
            local p, err = review.plan '- [ ] Move sent_to into the raw_stats PK in mss (MSG-3510)'
            assert.is_nil(p)
            assert.matches('no PR reference', err)
        end)

        it('refuses a plain prose line', function()
            assert.is_nil(review.plan '- [ ] Prepare for the elixir workshop')
        end)

        describe('argv', function()
            -- The whole reason `cls "prompt"` fails: --add-dir is variadic, so
            -- a prompt placed after it is swallowed as a second directory and
            -- claude exits with "Input must be provided...". Prompt first.
            it('puts the prompt before the variadic --add-dir', function()
                local p = assert(review.plan '- [ ] Review am#70 (MSG-3416)')
                assert.matches('claude$', p.argv[1])
                assert.matches('^Help me to draft an am pr review for this PR: https', p.argv[2])
                assert.equal('--dangerously-skip-permissions', p.argv[3])
                assert.equal('--add-dir', p.argv[4])
            end)

            -- Passed to vim.system as a list, so the URL is one argv element
            -- and never goes through a shell that could split or glob it.
            it('keeps the prompt as a single argument', function()
                local p = assert(review.plan '- [ ] Review am#70 (MSG-3416)')
                assert.equal(1, select(2, p.argv[2]:gsub('https://', '')))
            end)
        end)
    end)
end)
