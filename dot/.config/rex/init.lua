-- Overrides only: Rex ships its own defaults, so list just the keys we change.

-- Vim-style pane focus, alongside the default arrow-key bindings
rex.bind('cmd+alt+h', 'pane.focus.left')
rex.bind('cmd+alt+j', 'pane.focus.down')
rex.bind('cmd+alt+k', 'pane.focus.up')
rex.bind('cmd+alt+l', 'pane.focus.right')
