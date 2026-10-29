-- Overrides only: Rex ships its own defaults, so list just the keys we change.

-- Vim-style pane focus, alongside the default arrow-key bindings
rex.bind('cmd+alt+h', 'pane.focus.left')
rex.bind('cmd+alt+j', 'pane.focus.down')
rex.bind('cmd+alt+k', 'pane.focus.up')
rex.bind('cmd+alt+l', 'pane.focus.right')

rex.bind('cmd+r', 'client.tab.rename')

-- Cmd+W closes one pane; Cmd+Shift+W closes the whole tab and every pane in it
rex.action {
    name = 'close_tab',
    title = 'Close Tab',
    keywords = 'close window tab panes all',
    run = function(ctx, args)
        local _, err = rex.session.close_window {}
        if err ~= nil then
            error(err, 0)
        end
    end,
}
rex.bind('cmd+shift+w', 'close_tab')

-- BuJo tab: daily note on the left, Claude on the right, pinned as the first tab.
-- Commands go through initial_input so zsh aliases resolve and the shell survives quitting.
rex.action {
    name = 'bujo',
    title = 'Open BuJo Tab',
    keywords = 'bujo notes journal claude',
    run = function(ctx, args)
        local shell = 'com.superlogical.terminal.shell'
        local notes = os.getenv 'BUJO_NOTES_DIR' or (os.getenv 'HOME' .. '/notes')

        local view, err = rex.session.view {}
        if err ~= nil then
            error(err, 0)
        end

        local w
        w, err = rex.session.new_window {
            window_label = 'BuJo',
            layout = rex.layout.horizontal(
                0.5,
                rex.layout.block { flavor = shell, options = { cwd = notes, initial_input = 'bujo\n' } },
                rex.layout.block { flavor = shell, options = { cwd = notes, initial_input = 'cls\n' } }
            ),
        }
        if err ~= nil then
            error(err, 0)
        end

        local first = view.windows[1]
        if first ~= nil then
            _, err = rex.session.move_window { window_id = w.window_id, before_window_id = first.window_id }
            if err ~= nil then
                error(err, 0)
            end
        end

        return { window_id = w.window_id }
    end,
}
