return {
    'alvarosevilla95/luatab.nvim',
    dependencies = {
        'nvim-tree/nvim-web-devicons',
    },
    config = function()
        require('luatab').setup {
            title = function(bufnr)
                local file = require('luatab.helpers').filename(bufnr)
                local arrow_icon = require('arrow.statusline').text_for_statusline_with_icons()
                if arrow_icon and arrow_icon ~= '' then
                    return arrow_icon .. ' ' .. file
                end
                return file
            end,
        }
    end,
}
