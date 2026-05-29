return {
    'sphamba/smear-cursor.nvim',
    opts = {
        -- "Faster" preset from the README. Comments show the plugin defaults.
        stiffness = 0.8, --                      default 0.6   [0, 1]
        trailing_stiffness = 0.6, --             default 0.45  [0, 1]
        stiffness_insert_mode = 0.7, --          default 0.5   [0, 1]
        trailing_stiffness_insert_mode = 0.7, -- default 0.5   [0, 1]
        damping = 0.95, --                       default 0.85  [0, 1]
        damping_insert_mode = 0.95, --           default 0.9   [0, 1]
        distance_stop_animating = 0.5, --        default 0.1   > 0
    },
    -- Toggle at runtime with :SmearCursorToggle
}
