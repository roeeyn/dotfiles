-- Highlights the unique letter of each upcoming word on f/F/t/T, same
-- behavior as the main editor's eyeliner config. Colors come from
-- kanagawa's own lotus palette (not eyeliner's defaults, which are tuned
-- for dark backgrounds and wash out on the pale lotus background).
return {
    'jinh0/eyeliner.nvim',
    keys = { 'f', 'F', 't', 'T' },
    config = function()
        require('eyeliner').setup {
            highlight_on_key = true,
            dim = true,
        }

        -- kanagawa (priority 1000, lazy = false) has already applied the
        -- colorscheme by the time this runs, so these overrides win.
        local palette = require('kanagawa.colors').setup({ theme = 'lotus' }).palette
        vim.api.nvim_set_hl(0, 'EyelinerPrimary', { fg = palette.lotusRed, bold = true, underline = true })
        vim.api.nvim_set_hl(0, 'EyelinerSecondary', { fg = palette.lotusBlue4, underline = true })
    end,
}
