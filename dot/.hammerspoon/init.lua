local hyper = { 'cmd', 'alt' }

hs.loadSpoon 'SpoonInstall'
spoon.SpoonInstall.use_syncinstall = true
Install = spoon.SpoonInstall

local function read_api_key(file_path)
    local file = io.open(file_path, 'r') -- r read mode
    if not file then
        return nil
    end

    local content = file:read '*a' -- *a or *all reads the whole file
    file:close()

    return content:gsub('%s+$', '') -- remove trailing spaces
end

local api_key = read_api_key(os.getenv 'HOME' .. '/.unsplash_api_key')

Install:andUse('RandomBackground', {
    loglevel = 'debug',
    config = {
        unsplash_api_key = api_key,
    },
    start = true,
})

-- Keybindings for launching apps
local appKeys = {
    a = 'Slack',
    o = 'Obsidian',
    p = 'Postman',
    r = 'Arc',
    t = 'Alacritty',
    x = 'Firefox Developer Edition',
}

Install:andUse('Caffeine', {
    hotkeys = {
        toggle = { hyper, '/' },
    },
    start = true,
})

Caffeine = spoon.Caffeine
Caffeine:setState(true)

hs.hotkey.bind({ 'cmd', 'shift' }, 'V', function()
    hs.eventtap.keyStrokes(hs.pasteboard.getContents())
end)

-- Bind appKeys
for key, app in pairs(appKeys) do
    hs.hotkey.bind(hyper, key, function()
        hs.application.launchOrFocus(app)
    end)
end

-- FadeLogo is last to ensure that it confirms hammerspoon has fully loaded successfully
Install:andUse('FadeLogo', {
    config = {
        fade_in_time = 0,
        run_time = 0,
        fade_out_time = 0.4,
    },
    start = true,
})
