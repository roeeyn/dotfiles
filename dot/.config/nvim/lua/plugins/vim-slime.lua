-- vim-slime has no Rex target, so this overrides its hooks to drive the `rex`
-- CLI. Overrides are looked up as "SlimeOverride" .. capitalize(hook), and
-- capitalize lowercases the rest: ValidEnv must be named SlimeOverrideValidenv.
-- Rex addresses panes by block id, so unlike zellij nothing has to move focus
-- away from nvim and back.

local function rex_json(args)
    local out = vim.system(vim.list_extend({ 'rex' }, args), { text = true }):wait()
    if out.code ~= 0 then
        error('rex ' .. table.concat(args, ' ') .. ' failed: ' .. vim.trim(out.stderr or ''))
    end
    return vim.json.decode(out.stdout)
end

-- Flatten a window's layout tree into { block_id, x, y, w, h } leaves.
local function leaves(node, acc)
    acc = acc or {}
    if node.block_id then
        local r = node.rect
        table.insert(acc, { block_id = node.block_id, x = r[1], y = r[2], w = r[3], h = r[4] })
    elseif node.split then
        leaves(node.split.before, acc)
        leaves(node.split.after, acc)
    end
    return acc
end

--- The block slime should send to, chosen from the other panes in nvim's tab.
---
--- `others` is every other tiled pane in nvim's tab, each as
--- { block_id, label, x, y, w, h }. A lone neighbour is taken without asking;
--- with several, a menu lists them by label. Returns a block_id, or nil.
local function pick_target(others)
    if #others == 1 then
        return others[1].block_id
    end
    if #others == 0 then
        return nil
    end
    local items = { 'Send slime to which pane?' }
    for i, o in ipairs(others) do
        table.insert(items, string.format('%d. %s', i, o.label or o.block_id))
    end
    local choice = vim.fn.inputlist(items)
    return others[choice] and others[choice].block_id
end

local function config()
    local session, block = vim.env.REX_SESSION, vim.env.REX_BLOCK
    if not session or not block then
        error 'vim-slime: nvim is not running inside a Rex pane'
    end
    local window = rex_json({ 'block', 'inspect', '-s', session, block, '--json' }).block.window_id
    local me, others = nil, {}
    for _, w in ipairs(rex_json({ 'session', 'inspect', session, '--json' }).windows) do
        if w.window_id == window then
            for _, layer in ipairs(w.layers) do
                if layer.kind == 'tiled' then
                    local labels = {}
                    for _, b in ipairs(layer.blocks) do
                        labels[b.block_id] = b.label
                    end
                    for _, leaf in ipairs(leaves(layer.layout)) do
                        leaf.label = labels[leaf.block_id]
                        if leaf.block_id == block then
                            me = leaf
                        else
                            table.insert(others, leaf)
                        end
                    end
                end
            end
        end
    end
    local target = me and pick_target(others)
    if not target then
        error 'vim-slime: no target pane picked'
    end
    vim.b.slime_config = { session_id = session, block_id = target }
end

local function send(cfg, text)
    -- Same bracketed-paste wrapping the built-in targets use, so multi-line
    -- blocks reach a REPL as one paste instead of line-by-line input.
    local wrapped = vim.fn['slime#common#bracketed_paste'](text)
    local bracketed, payload, has_crlf = wrapped[1], wrapped[2], wrapped[3]
    if bracketed ~= 0 and bracketed ~= false then
        payload = '\27[200~' .. payload .. '\27[201~' .. (has_crlf == 1 and '\n' or '')
    end
    -- On stdin, so text starting with `-` isn't read as a flag; synchronous,
    -- like the built-in targets, so consecutive sends can't arrive out of order.
    local out = vim.system({ 'rex', 'send', '-s', cfg.session_id, '-b', cfg.block_id }, { stdin = payload, text = true }):wait()
    if out.code ~= 0 then
        vim.notify('vim-slime: rex send failed — ' .. vim.trim(out.stderr or ''), vim.log.levels.ERROR)
    end
end

local function valid_config(cfg)
    return type(cfg) == 'table' and cfg.session_id ~= nil and cfg.block_id ~= nil
end

return {
    'jpalardy/vim-slime',
    init = function()
        -- Any built-in target works here; every hook it would use is overridden below.
        vim.g.slime_target = 'neovim'
        _G.rex_slime = { config = config, send = send, valid_config = valid_config }
        vim.cmd [[
            function! SlimeOverrideConfig() abort
              call v:lua.rex_slime.config()
            endfunction
            function! SlimeOverrideSend(config, text) abort
              call v:lua.rex_slime.send(a:config, a:text)
            endfunction
            function! SlimeOverrideValidenv() abort
              return !empty($REX_SESSION) && !empty($REX_BLOCK)
            endfunction
            function! SlimeOverrideValidconfig(config, silent) abort
              return v:lua.rex_slime.valid_config(a:config)
            endfunction
        ]]
    end,
}
