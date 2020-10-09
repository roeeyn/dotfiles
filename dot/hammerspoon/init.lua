hyper = {"cmd","alt"}

hs.loadSpoon("SpoonInstall")
spoon.SpoonInstall.use_syncinstall = true
Install=spoon.SpoonInstall

Install:andUse("UnsplashRandom")

-- Keybindings for launching apps
appKeys = {
  c = "Google Chrome",
  d = "Finder",
  e = "Emacs",
  f = "Franz",
  k = "Calendar",
  p = "Postman",
  s = "Spotify",
  t = "iTerm",
  v = "Visual Studio Code",
  x = "Firefox Developer Edition",
}

hs.hotkey.bind({"cmd", "alt", "shift"}, "V", function() hs.eventtap.keyStrokes(hs.pasteboard.getContents()) end)

-- Bind appKeys
for key, app in pairs(appKeys)
do
  hs.hotkey.bind(hyper, key, function()
                   hs.application.launchOrFocus(app)
  end)
end

-- FadeLogo is last to ensure that it confirms hammerspoon has fully loaded successfully
Install:andUse("FadeLogo",
               {
                 config = {
                   fade_in_time = 0,
                   run_time = 0,
                   fade_out_time = 0.4
                 },
                 start = true
               }
)
