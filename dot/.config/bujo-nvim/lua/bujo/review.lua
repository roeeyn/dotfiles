-- bujo.review — launch a PR-review agent from a task line.
--
-- A review task in a daily note carries everything the launch needs:
--
--     - [ ] Review template-view coverage am#70 (MSG-3416)
--                                        ^^^^^   ^^^^^^^^
--                                        PR ref  ticket
--
-- so `:BujoReview` reads the cursor line, reconstructs the PR URL through
-- bujo.links, and opens a zellij tab running an interactive agent already
-- prompted to run the review. Same three steps done by hand — new tab, cd
-- to src, prompt the agent — minus the retyping.
--
-- Two review kinds (M.config.kinds), one key each:
--   <leader>tr  `am`     /am-code-review --pr, the team's skill    → `CR: `
--   <leader>tR  `draft`  draft-am-pr-review, Codex findings in /tmp → `CR!: `

local links = require 'bujo.links'

local M = {}

M.config = {
    -- Where the agent runs. The review skill fans out across repos, so it
    -- wants the src root, not a single checkout.
    cwd = vim.fs.normalize '~/src',
    -- Absolute, because the zellij server does not inherit an interactive
    -- shell's PATH.
    cmd = '/opt/homebrew/bin/claude',
    -- `cls` in .zshrc. NOT reused as an alias: aliases only exist in an
    -- interactive zsh, and the tab is spawned without a shell at all.
    args = { '--dangerously-skip-permissions', '--add-dir', vim.fs.normalize '~/src' },
    -- Two review flavors share everything but the prompt and the tab label.
    -- `am` is the team's official skill, invoked by its literal slash name:
    -- both skills claim "review this PR" in their descriptions, so prose would
    -- be a coin flip. `--pr` is required: a bare argument is read as a local
    -- git base, not a PR. `draft` stays prose because it is tuned to its skill.
    default_kind = 'am',
    kinds = {
        am = { prompt = '/am-code-review --pr %s', tab_prefix = 'CR: ' },
        draft = { prompt = 'Help me to draft an am pr review for this PR: %s', tab_prefix = 'CR!: ' },
    },
}

--- Everything needed to launch a review for `line`, or nil + reason.
---
--- Pure: no buffers, no processes, no config reads beyond M.config. The
--- launch side effects live in M.launch, so this half can be spec'd.
---
--- `kind` picks an entry of M.config.kinds (default M.config.default_kind).
--- Returns { url, ticket, ref, tab_name, argv }.
function M.plan(line, kind)
    kind = kind or M.config.default_kind
    local flavor = M.config.kinds[kind]
    if not flavor then
        return nil, string.format('unknown review kind %q', kind)
    end

    local pr, ticket
    for _, r in ipairs(links.refs(line)) do
        if not pr and (r.kind == 'github' or r.kind == 'bitbucket') then
            pr = r
        elseif not ticket and r.kind == 'jira' then
            ticket = r.ref
        end
    end

    if not pr then
        return nil, 'no PR reference on this line'
    end

    local url = links.resolve(pr.ref)
    if not url then
        return nil, string.format('could not resolve %q', pr.ref)
    end
    -- links.resolve emits /issues/N and leans on GitHub's redirect to /pull/N.
    -- The review skill parses the URL itself, so hand it the real PR form
    -- rather than one that only works because a redirect exists.
    url = url:gsub('/issues/(%d+)$', '/pull/%1')

    -- The ticket is the useful tab label (`CR: MSG-3416`); the PR ref is the
    -- fallback, so a line with a PR but no ticket still names its tab.
    local argv = { M.config.cmd, string.format(flavor.prompt, url) }
    vim.list_extend(argv, M.config.args)

    return {
        url = url,
        ticket = ticket,
        ref = pr.ref,
        tab_name = flavor.tab_prefix .. (ticket or pr.ref),
        argv = argv,
    }
end

--- Launch the review for the line under the cursor.
---
--- Only ever runs `zellij action new-tab`. Every other zellij action verb
--- (close-tab, go-to-tab, ...) targets the *focused* tab rather than one you
--- name, so a stray cleanup call kills whatever the user is looking at —
--- creating a tab is the one operation here that cannot hit the wrong target.
--- The note is never written to either: launching an agent is not a BuJo state
--- change, and `[<]` means scheduled, not delegated.
function M.launch(kind)
    if vim.env.ZELLIJ == nil then
        vim.notify('bujo: not inside a zellij session', vim.log.levels.WARN)
        return
    end

    local plan, err = M.plan(vim.api.nvim_get_current_line(), kind)
    if not plan then
        vim.notify('bujo: ' .. err, vim.log.levels.WARN)
        return
    end

    local cmd = { 'zellij', 'action', 'new-tab', '--name', plan.tab_name, '--cwd', M.config.cwd, '--' }
    vim.list_extend(cmd, plan.argv)

    vim.system(cmd, { text = true }, function(out)
        vim.schedule(function()
            if out.code == 0 then
                vim.notify('bujo: launched ' .. plan.tab_name, vim.log.levels.INFO)
            else
                vim.notify('bujo: zellij failed — ' .. vim.trim(out.stderr or ''), vim.log.levels.ERROR)
            end
        end)
    end)
end

function M.setup(opts)
    M.config = vim.tbl_deep_extend('force', M.config, opts or {})
    vim.api.nvim_create_user_command('BujoReview', function(o)
        M.launch(o.args ~= '' and o.args or nil)
    end, {
        nargs = '?',
        complete = function()
            return vim.tbl_keys(M.config.kinds)
        end,
        desc = 'Review the PR ref on this line in a new zellij tab ([kind]: am, draft)',
    })

    -- Two keys on purpose: this spawns a real agent that spends real tokens,
    -- so it should not sit one fat-fingered keypress away from the single-key
    -- maps next door (<leader>a adds a task, <leader>x toggles a checkbox).
    vim.keymap.set('n', '<leader>tr', function()
        M.launch 'am'
    end, { desc = '[Trigger] Review the PR on this line with /am-code-review --pr (new zellij tab)' })
    vim.keymap.set('n', '<leader>tR', function()
        M.launch 'draft'
    end, { desc = '[Trigger] Draft Codex review findings for the PR on this line (new zellij tab)' })
end

return M
