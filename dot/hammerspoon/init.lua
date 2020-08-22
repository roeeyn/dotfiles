hyper = {"cmd","alt"}

-- Keybindings for launching apps
appKeys = {
  c = "Google Chrome",
  d = "Finder",
  e = "Emacs",
  f = "Franz",
  k = "Calendar",
  p = "Postman",
  n = "Notion",
  s = "Spotify",
  t = "iTerm",
  x = "Firefox Developer Edition",
}
-- Bind appKeys
for key, app in pairs(appKeys)
do
  hs.hotkey.bind(hyper, key, function()
                   hs.application.launchOrFocus(app)
  end)
end
