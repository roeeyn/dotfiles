-- Specs for bujo.migrate — run with `make test` from the app config dir, or:
--   NVIM_APPNAME=bujo-nvim nvim --headless \
--     -u tests/minimal_init.lua \
--     -c "PlenaryBustedDirectory tests/ { minimal_init = 'tests/minimal_init.lua' }"

local migrate = require('bujo.migrate').migrate

describe('bujo.migrate', function()
    it('migrates flat pending tasks and marks them in the source', function()
        local today, source = migrate {
            '# Friday, 2026-07-10',
            '',
            '- [ ] call the bank',
            '- [x] ship the PR',
            '- [ ] water plants',
        }

        assert.same({
            '- [ ] call the bank',
            '- [ ] water plants',
        }, today)
        assert.same({
            '# Friday, 2026-07-10',
            '',
            '- [>] call the bank',
            '- [x] ship the PR',
            '- [>] water plants',
        }, source)
    end)

    it('copies whole blocks verbatim, including non-task children', function()
        local today, source = migrate {
            '- [ ] plan the offsite',
            '    - [x] book room',
            '    - [ ] send invites',
            '    - remember Luis is out on Friday',
            '- [x] closed task',
            '    - a note under a closed task',
        }

        assert.same({
            '- [ ] plan the offsite',
            '    - [x] book room',
            '    - [ ] send invites',
            '    - remember Luis is out on Friday',
        }, today)
        assert.same({
            '- [>] plan the offsite',
            '    - [x] book room',
            '    - [>] send invites',
            '    - remember Luis is out on Friday',
            '- [x] closed task',
            '    - a note under a closed task',
        }, source)
    end)

    it('handles deep nesting (3+ levels) with free text', function()
        local input = {
            '- [ ] release v2',
            '    - [ ] cut branch',
            '        - [ ] bump version',
            '            see RELEASING.md for the ritual',
            '    - [ ] announce',
        }
        local today, source = migrate(input)

        assert.same(input, today)
        assert.same({
            '- [>] release v2',
            '    - [>] cut branch',
            '        - [>] bump version',
            '            see RELEASING.md for the ritual',
            '    - [>] announce',
        }, source)
    end)

    it('rescues an unchecked child under a resolved parent, dedented to column 0', function()
        local today, source = migrate {
            '- [x] migrate the database',
            '    - [ ] delete the old snapshots',
            '        keep the 2025 ones',
            '- [-] no longer relevant',
            '    - [ ] but this child still is',
        }

        assert.same({
            '- [ ] delete the old snapshots',
            '    keep the 2025 ones',
            '- [ ] but this child still is',
        }, today)
        assert.same({
            '- [x] migrate the database',
            '    - [>] delete the old snapshots',
            '        keep the 2025 ones',
            '- [-] no longer relevant',
            '    - [>] but this child still is',
        }, source)
    end)

    it('returns nothing when there are zero pending tasks', function()
        local input = {
            '# Thursday, 2026-07-09',
            '',
            '- [x] all done',
            'a free-floating thought',
        }
        local today, source = migrate(input)

        assert.same({}, today)
        assert.same(input, source)
    end)

    it('leaves x, >, <, - states alone', function()
        local input = {
            '- [x] done',
            '- [>] already migrated',
            '- [<] scheduled for the 20th',
            '- [-] irrelevant now',
        }
        local today, source = migrate(input)

        assert.same({}, today)
        assert.same(input, source)
    end)

    it('preserves block order and indentation across mixed content', function()
        local today, source = migrate {
            '# Friday, 2026-07-10',
            '',
            '- [ ] first',
            'some prose between tasks',
            '- [ ] second',
            '    - child of second',
            '',
            '- [ ] third after a blank line',
        }

        assert.same({
            '- [ ] first',
            '- [ ] second',
            '    - child of second',
            '- [ ] third after a blank line',
        }, today)
        assert.same({
            '# Friday, 2026-07-10',
            '',
            '- [>] first',
            'some prose between tasks',
            '- [>] second',
            '    - child of second',
            '',
            '- [>] third after a blank line',
        }, source)
    end)

    it('ends a block at a blank line even if deeper content follows', function()
        local today, source = migrate {
            '- [ ] parent',
            '    - [ ] child',
            '',
            '    stray indented prose, not part of the block',
        }

        assert.same({
            '- [ ] parent',
            '    - [ ] child',
        }, today)
        assert.same({
            '- [>] parent',
            '    - [>] child',
            '',
            '    stray indented prose, not part of the block',
        }, source)
    end)
end)
