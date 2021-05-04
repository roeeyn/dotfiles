hyper = {"cmd", "alt"}

hs.loadSpoon("SpoonInstall")
spoon.SpoonInstall.use_syncinstall = true
Install = spoon.SpoonInstall

Install:andUse("UnsplashRandom")

-- Keybindings for launching apps
appKeys = {
    a = "Slack",
    c = "Google Chrome",
    d = "DataGrip",
    e = "Emacs",
    -- f = "Franz",
    l = "Telegram",
    m = "Spark",
    p = "Postman",
    s = "Spotify",
    t = "iTerm",
    v = "Visual Studio Code",
    w = "WhatsApp",
    x = "Firefox Developer Edition"
}

Install:andUse(
    "Caffeine",
    {
        hotkeys = {
            toggle = {hyper, "/"}
        },
        start = true
    }
)

hs.hotkey.bind(
    {"cmd", "alt", "shift"},
    "V",
    function()
        hs.eventtap.keyStrokes(hs.pasteboard.getContents())
    end
)

-- Bind appKeys
for key, app in pairs(appKeys) do
    hs.hotkey.bind(
        hyper,
        key,
        function()
            hs.application.launchOrFocus(app)
        end
    )
end

-- FadeLogo is last to ensure that it confirms hammerspoon has fully loaded successfully
Install:andUse(
    "FadeLogo",
    {
        config = {
            fade_in_time = 0,
            run_time = 0,
            fade_out_time = 0.4
        },
        start = true
    }
)
