-- bujo.links — short ticket/PR references instead of full markdown links.
--
-- Neovim wraps on raw buffer columns even when text is concealed
-- (neovim/neovim#14409), so lines carrying full URLs wrap weirdly under
-- render-markdown. The fix is to keep the URL out of the line: raw text says
-- `MSG-1234` or `repo#56`, the URL is reconstructed on demand (gx /
-- <leader>o), and refs are decorated in place to look like rendered links.

local M = {}

-- The org's conventions. Edit here (or pass overrides via
-- require('bujo').setup { links = { ... } }).
M.config = {
    -- Vault root, so `[[wikilinks]]` can resolve to files. bujo.setup()
    -- overrides this with its own M.root; the default only matters when
    -- links.lua is required directly (specs).
    root = vim.fs.normalize(vim.env.BUJO_NOTES_DIR or '~/notes'),
    jira = 'https://alertmedia.atlassian.net/browse/', -- <TICKET> appended
    github = 'https://github.com/alertmediainc/', -- <repo>/issues/<n> appended
    bitbucket = 'https://bitbucket.org/alertmediaadmin/', -- <repo>/pull-requests/<n>
    -- Repos still on Bitbucket; delete an entry once it migrates to GitHub.
    -- notify_me migrated the week of 2026-07-27: refs from before then are
    -- Bitbucket PR numbers and no longer resolve (accepted breakage).
    bitbucket_repos = {},
    -- Short names for long repos; anything not listed is used verbatim.
    aliases = {
        nr = 'notification_router',
        mss = 'messaging_stats_service',
        ['tf-modules'] = 'terraform-modules',
    },
}

local function expand_alias(name)
    return M.config.aliases[name] or name
end

-- Equal-length space run, so gsub masking preserves byte positions.
local function blank(m)
    return (' '):rep(#m)
end

-- Bare URLs match greedily (%S+), which drags in closing punctuation that
-- belongs to the prose, not the URL: `(see https://x.test)`,
-- `https://x.test, then...`. Trim it off before the URL becomes a ref,
-- keeping a trailing `)` for each unmatched `(` inside the URL so
-- wikipedia-style `Foo_(bar)` paths survive (same policy as GitHub/Slack
-- linkifiers).
local function trim_url(url)
    while true do
        local last = url:sub(-1)
        if last:match '[.,;:!?]' then
            url = url:sub(1, -2)
        elseif last == ')' then
            local _, opens = url:gsub('%(', '')
            local _, closes = url:gsub('%)', '')
            if closes <= opens then
                break
            end
            url = url:sub(1, -2)
        else
            break
        end
    end
    return url
end

--- All link references in a line, as { ref, kind, from, to } with 1-based
--- inclusive byte columns. kind is 'jira' | 'github' | 'bitbucket' | 'url' |
--- 'note'.
---
--- For 'note' refs `ref` is the resolved destination (the `[[dest|alias]]`
--- left half), while from/to span the whole `[[...]]` including the brackets —
--- so gx fires anywhere on the link, concealed brackets included. Every other
--- kind has ref == line:sub(from, to).
function M.refs(line)
    -- Inline markdown links and <autolinks> already carry their own URL and
    -- their own render-markdown decoration; blank them before any scanning.
    line = line:gsub('%[[^%]]-%]%([^%)]-%)', blank):gsub('<https?://[^%s>]*>', blank)
    local out = {}

    -- [[wikilinks]] → notes in the vault. Scanned before URLs and tickets so
    -- a note titled `MSG-3111 postmortem` isn't also read as a Jira ref.
    for from, inner, after in line:gmatch '()%[%[([^%[%]]-)%]%]()' do
        -- Bash test expressions (`[[ -n "$x" ]]`, `[[ $# -gt 0 ]]`) are the one
        -- false positive that matters — the vault's how-to notes are full of
        -- them. `[[` is a shell *keyword*, so it always has a space after it;
        -- requiring no padding inside the brackets rejects every one of them
        -- and matches the Obsidian convention we actually write.
        if inner ~= '' and not inner:match '^%s' and not inner:match '%s$' then
            local dest = vim.trim(inner:match '^([^|]*)') -- [[dest|alias]]
            if dest ~= '' then
                out[#out + 1] = { ref = dest, kind = 'note', from = from, to = after - 1 }
            end
        end
    end
    -- Blanked whether or not it became a ref, so bash `[[ "$x" == "MSG-1" ]]`
    -- inside a fenced block doesn't leak a ticket ref either.
    line = line:gsub('%[%[[^%[%]]-%]%]', blank)

    -- Bare URLs, opened verbatim. Scanned first, then blanked, so a URL's
    -- path can't be misread as a ticket ref by the passes below.
    for from, url in line:gmatch '()(https?://%S+)' do
        url = trim_url(url)
        out[#out + 1] = { ref = url, kind = 'url', from = from, to = from + #url - 1 }
    end
    line = line:gsub('https?://%S+', blank)

    -- repo#NN — the greedy char set makes the start boundary automatic.
    for from, ref, after in line:gmatch '()([%w_.%-]+#%d+)()' do
        if not line:sub(after, after):match '%w' then
            local repo = expand_alias(ref:match '^(.+)#')
            local kind = M.config.bitbucket_repos[repo] and 'bitbucket' or 'github'
            out[#out + 1] = { ref = ref, kind = kind, from = from, to = after - 1 }
        end
    end

    -- JIRA-123, skipping any span already claimed by a repo ref above.
    for from, ref, after in line:gmatch '()(%u+%-%d+)()' do
        local free = not line:sub(from - 1, from - 1):match '[%w%-]' and not line:sub(after, after):match '%w'
        for _, r in ipairs(out) do
            free = free and (after - 1 < r.from or from > r.to)
        end
        if free then
            out[#out + 1] = { ref = ref, kind = 'jira', from = from, to = after - 1 }
        end
    end

    table.sort(out, function(a, b)
        return a.from < b.from
    end)
    return out
end

--- Reconstruct the URL for a single reference, or nil if it isn't one.
function M.resolve(ref)
    if ref:match '^https?://' then
        return ref -- a bare URL already is its own URL
    end
    if ref:match '^%u+%-%d+$' then
        return M.config.jira .. ref
    end
    local name, num = ref:match '^([%w_.%-]+)#(%d+)$'
    if not name then
        return nil
    end
    name = expand_alias(name)
    if M.config.bitbucket_repos[name] then
        return M.config.bitbucket .. name .. '/pull-requests/' .. num
    end
    -- GitHub redirects /issues/N to /pull/N when it's a PR, so one form
    -- covers tickets and PRs alike.
    return M.config.github .. name .. '/issues/' .. num
end

--- Filename stem bujo uses for a note title:
--- `Broadway 101 Elixir Pipelines` → `broadway-101-elixir-pipelines`.
--- Shared with bujo.open_named_note (`:BujoNote`), which creates the files this
--- resolves — a second copy of this rule would silently strand links.
function M.slug(name)
    return (name:lower():gsub('%s+', '-'):gsub('[^%w%-]', ''):gsub('%-%-+', '-'):gsub('^%-+', ''):gsub('%-+$', ''))
end

--- Absolute path for a `[[wikilink]]` destination, or nil when nothing matches.
---
--- The vault names notes two ways — verbatim titles (`Load Testing Guide.md`)
--- and kebab stems (`elixir-broadway-tips.md`) — and links are written in
--- both, so resolution walks a ladder from most to least literal. Nothing is
--- created here: a dangling link stays dangling (the vault already has one),
--- and gx warns rather than guessing which naming style a new file should use.
function M.note_path(name)
    local stat = (vim.uv or vim.loop).fs_stat
    local root = M.config.root

    -- [[2026-08-05]] → a daily note, which lives under YYYY/MM/ not notes/.
    local y, m = name:match '^(%d%d%d%d)%-(%d%d)%-%d%d$'
    if y then
        local daily = string.format('%s/%s/%s/%s.md', root, y, m, name)
        if stat(daily) then
            return daily
        end
    end

    -- Matching is done against a directory listing rather than by stat-ing a
    -- built path: APFS is case-insensitive, so a stat on `broadway 101 elixir pipelines.md`
    -- happily succeeds for `Broadway 101 Elixir Pipelines.md` and we'd hand back a path that
    -- isn't the file's real name (wrong buffer name here, outright miss on a
    -- case-sensitive volume). The listing gives us the on-disk spelling.
    local exact, folded = {}, {}
    for _, f in ipairs(vim.fn.glob(root .. '/notes/*.md', true, true)) do
        local stem = vim.fn.fnamemodify(f, ':t:r')
        exact[stem] = f
        folded[stem:lower()] = f
    end

    -- Verbatim title, then the kebab stem `:BujoNote` would have written, then
    -- case-folded — so `[[Broadway 101 Elixir Pipelines]]`, `[[broadway-101-elixir-pipelines]]` and
    -- `[[broadway 101 elixir pipelines]]` all land on the same note.
    return exact[name] or exact[M.slug(name)] or folded[name:lower()]
end

--- The reference record under 1-based byte column `col`, or nil.
function M.ref_at(line, col)
    for _, r in ipairs(M.refs(line)) do
        if col >= r.from and col <= r.to then
            return r
        end
    end
end

--- Target for the reference under 1-based byte column `col`, plus its kind:
--- a file path for 'note' refs, a URL for every other kind. nil when the
--- column isn't on a reference (or a note ref that resolves to no file).
function M.find(line, col)
    local r = M.ref_at(line, col)
    if not r then
        return nil
    end
    if r.kind == 'note' then
        return M.note_path(r.ref), 'note'
    end
    return M.resolve(r.ref), r.kind
end

local function pattern_escape(s)
    return (s:gsub('[%^%$%(%)%%%.%[%]%*%+%-%?]', '%%%0'))
end

--- Canonical short reference for one of our URLs (aliases preferred), or
--- nil for foreign URLs. Tolerates trailing paths like /overview or /files.
function M.url_to_ref(url)
    local ticket = url:match('^' .. pattern_escape(M.config.jira) .. '(%u+%-%d+)')
    if ticket then
        return ticket
    end

    local name, num
    local gh_name, seg, gh_num = url:match('^' .. pattern_escape(M.config.github) .. '([%w_.%-]+)/(%a+)/(%d+)')
    if gh_name and (seg == 'pull' or seg == 'issues') then
        name, num = gh_name, gh_num
    else
        name, num = url:match('^' .. pattern_escape(M.config.bitbucket) .. '([%w_.%-]+)/pull%-requests/(%d+)')
    end
    if not name then
        return nil
    end

    for alias, full in vim.spairs(M.config.aliases) do
        if full == name then
            name = alias
            break
        end
    end
    return name .. '#' .. num
end

-- Alias-expanded identity, so `nr#52` and `notification_router#52` compare equal.
local function identity(ref)
    local name, num = ref:match '^([%w_.%-]+)#(%d+)$'
    if name then
        return expand_alias(name) .. '#' .. num
    end
    return ref
end

--- Rewrite `[label](url)` links whose URL reconstructs from the label into
--- the bare label. Prose labels, foreign URLs, and mismatched pairs are left
--- untouched. Pure; returns the new lines and how many links were shortened.
function M.shorten(lines)
    local count = 0
    local out = {}
    for i, line in ipairs(lines) do
        out[i] = line:gsub('%[([^%]]-)%]%(([^%)]-)%)', function(label, url)
            local ref = M.url_to_ref(url)
            if ref and identity(label) == identity(ref) then
                count = count + 1
                return label
            end
            return string.format('[%s](%s)', label, url)
        end)
    end
    return out, count
end

--- :BujoShortenLinks — apply M.shorten to the current buffer.
function M.shorten_buffer()
    local new, count = M.shorten(vim.api.nvim_buf_get_lines(0, 0, -1, false))
    if count > 0 then
        vim.api.nvim_buf_set_lines(0, 0, -1, false, new)
    end
    vim.notify(string.format('bujo: shortened %d link(s)', count), vim.log.levels.INFO)
end

--- gx replacement: open the ref under the cursor; otherwise fall back to
--- builtin gx behavior (treesitter-aware URL extraction, then <cfile>).
---
--- Note refs open in this window rather than the browser — that's the whole
--- point of `[[wikilinks]]`, and it's why the fallback chain below is skipped
--- for them: an unresolved note must warn, not quietly hand a note title to
--- <cfile> and open some unrelated path.
function M.open()
    local line, col = vim.api.nvim_get_current_line(), vim.api.nvim_win_get_cursor(0)[2] + 1

    local ref = M.ref_at(line, col)
    if ref and ref.kind == 'note' then
        local path = M.note_path(ref.ref)
        if not path then
            vim.notify(string.format('bujo: no note matching %q', ref.ref), vim.log.levels.WARN)
            return
        end
        vim.cmd.edit(vim.fn.fnameescape(path))
        return
    end

    local url = ref and M.resolve(ref.ref)
    if not url then
        local ok, urls = pcall(function()
            return require('vim.ui')._get_urls()
        end)
        url = ok and urls[1] or vim.fn.expand '<cfile>'
    end
    if not url or url == '' then
        return
    end
    local _, err = vim.ui.open(url)
    if err then
        vim.notify('bujo: ' .. err, vim.log.levels.WARN)
    end
end

-- Decoration -----------------------------------------------------------------
-- Bare refs get render-markdown's link look: icon prefix + underlined label.
-- Persistent extmarks recomputed per change, NOT an ephemeral decoration
-- provider: inline virt_text must take part in line layout, which is already
-- fixed by the time on_line callbacks run, so ephemeral inline marks are
-- silently not rendered. Notes are tiny; whole-buffer recompute is cheap.

local ns = vim.api.nvim_create_namespace 'bujo-links'

-- url reuses render-markdown's default hyperlink icon (link.hyperlink),
-- so bare URLs and <autolink>s look the same. There is deliberately no 'note'
-- entry: `[[wikilinks]]` are a real tree-sitter node, so render-markdown
-- already draws them (link.wiki — 󱗖 icon, brackets concealed) exactly as it
-- does <autolinks>. We only take over gx for them, never the look.
local ICONS = { jira = '󰖟 ', github = '󰊤 ', bitbucket = '󰂨 ', url = '󰌹 ' }

--- Re-scan `buf` and decorate every bare ref with an icon + link styling.
function M.decorate(buf)
    vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
    for row, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
        for _, r in ipairs(M.refs(line)) do
            if ICONS[r.kind] then
                vim.api.nvim_buf_set_extmark(buf, ns, row - 1, r.from - 1, {
                    end_col = r.to,
                    hl_group = 'BujoRef',
                    virt_text = { { ICONS[r.kind], 'BujoRefIcon' } },
                    virt_text_pos = 'inline',
                })
            end
        end
    end
end

function M.setup(opts)
    M.config = vim.tbl_deep_extend('force', M.config, opts or {})

    -- Same styling render-markdown uses for real links.
    vim.api.nvim_set_hl(0, 'BujoRef', { default = true, link = '@markup.link.label.markdown_inline' })
    vim.api.nvim_set_hl(0, 'BujoRefIcon', { default = true, link = 'RenderMarkdownLink' })

    vim.keymap.set('n', 'gx', M.open, { desc = 'Open note, ticket/PR ref, or link under cursor' })
    vim.keymap.set('n', '<leader>o', M.open, { desc = 'Open note, ticket/PR ref, or link under cursor' })

    vim.api.nvim_create_user_command('BujoShortenLinks', M.shorten_buffer, { desc = 'Rewrite [ref](url) links into bare ticket/PR refs' })

    local group = vim.api.nvim_create_augroup('bujo-links', { clear = true })
    vim.api.nvim_create_autocmd('FileType', {
        group = group,
        pattern = 'markdown',
        callback = function(a)
            M.decorate(a.buf)
            if vim.b[a.buf].bujo_links then
                return
            end
            vim.b[a.buf].bujo_links = true
            vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI' }, {
                group = group,
                buffer = a.buf,
                callback = function()
                    M.decorate(a.buf)
                end,
            })
        end,
    })
end

return M
