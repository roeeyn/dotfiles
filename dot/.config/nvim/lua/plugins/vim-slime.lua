return {
    'jpalardy/vim-slime',
    init = function()
        -- vim-slime has a native zellij dispatcher (autoload/slime/targets/zellij.vim):
        -- it sends text by focusing the neighbour pane, running `zellij action
        -- write-chars`, then focusing back. So the target must be a DIRECTIONAL
        -- neighbour in the same tab, not an arbitrary pane id.
        vim.g.slime_target = 'zellij'

        -- Prompt on the first send per buffer (then it's cached in b:slime_config),
        -- but pre-fill these defaults so the common case is just <Enter><Enter>.
        --   session_id    = "current" -> the session nvim lives in
        --   relative_pane = "right"   -> REPL is the pane to the right of nvim
        -- Edit the prompt to "down"/"left"/"up" when the REPL sits elsewhere.
        vim.g.slime_default_config = { session_id = 'current', relative_pane = 'right' }
    end,
}
