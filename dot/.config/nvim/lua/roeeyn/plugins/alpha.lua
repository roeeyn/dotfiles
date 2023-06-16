local M = {}

function M.setup()
    local status_ok, alpha = pcall(require, 'alpha')
    if not status_ok then
        return
    end

    require 'alpha'
    require 'alpha.term'
    local dashboard = require 'alpha.themes.dashboard'

    dashboard.section.buttons.val = {
        dashboard.button('f', '  Find file', ':Telescope find_files<CR>'),
        dashboard.button('h', '  Harpoon Files', ":lua require('roeeyn.plugins.harpoon').open_harpoon_telescope()<CR>"),
        dashboard.button('t', '  Find text', ':Telescope live_grep <CR>'),
        dashboard.button('q', '  Quit Neovim', ':qa<CR>'),
    }

    for _, button in ipairs(dashboard.section.buttons.val) do
        button.opts.hl = 'AlphaButtons'
        button.opts.hl_shortcut = 'AlphaShortcut'
    end

    dashboard.section.header.opts.hl = 'Type'
    dashboard.section.buttons.opts.hl = 'AlphaButtons'
    dashboard.section.footer.opts.hl = 'Type'

    -- Text ASCII art
    -- https://patorjk.com/software/taag/#p=display&v=0&f=ANSI%20Shadow&t=NEOVIM

    -- Great Image Art
    -- https://github.com/goolord/alpha-nvim/discussions/16?sort=top#discussioncomment-4568824
    --
    -- Image to ANSI
    -- https://dom111.github.io/image-to-ansi/
    -- With UNICODE, True colour, and 56x45

    local personal_header = {
        [[██████╗  ██████╗ ███████╗███████╗██╗   ██╗███╗   ██╗]],
        [[██╔══██╗██╔═══██╗██╔════╝██╔════╝╚██╗ ██╔╝████╗  ██║]],
        [[██████╔╝██║   ██║█████╗  █████╗   ╚████╔╝ ██╔██╗ ██║]],
        [[██╔══██╗██║   ██║██╔══╝  ██╔══╝    ╚██╔╝  ██║╚██╗██║]],
        [[██║  ██║╚██████╔╝███████╗███████╗   ██║   ██║ ╚████║]],
        [[╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚══════╝   ╚═╝   ╚═╝  ╚═══╝]],
    }

    math.randomseed(os.time())

    local arts = {
        'thinking',
        'thisisfine',
        'rayquaza',
    }

    local height = 25 -- two pixels per vertical space
    local randomIdx = math.random(#arts)

    dashboard.section.terminal.command = 'cat | ' .. os.getenv 'HOME' .. '/.dotfiles/art/' .. arts[randomIdx] .. '.sh'
    dashboard.section.terminal.height = height
    dashboard.section.terminal.opts.redraw = true

    dashboard.section.header.val = personal_header

    local function footer()
        -- Number of plugins
        local total_plugins = #vim.tbl_keys(packer_plugins)
        local datetime = os.date '%d-%m-%Y %H:%M:%S'
        local plugins_text = '   '
            .. total_plugins
            .. ' plugins'
            .. '   v'
            .. vim.version().major
            .. '.'
            .. vim.version().minor
            .. '.'
            .. vim.version().patch
            .. '   '
            .. datetime

        -- Quote
        local fortune = require 'alpha.fortune'
        local quote = table.concat(fortune(), '\n')

        return plugins_text .. '\n' .. quote
    end

    dashboard.section.footer.val = footer()

    dashboard.config.layout = {
        { type = 'padding', val = 1 },
        dashboard.section.terminal,
        { type = 'padding', val = 5 },
        dashboard.section.header,
        { type = 'padding', val = 2 },
        dashboard.section.buttons,
        { type = 'padding', val = 1 },
        dashboard.section.footer,
    }

    dashboard.config.opts.noautocmd = false
    alpha.setup(dashboard.opts)
end

return M
