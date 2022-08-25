local hyper = { "cmd", "alt" }

hs.loadSpoon("SpoonInstall")
spoon.SpoonInstall.use_syncinstall = true
Install = spoon.SpoonInstall

Install:andUse("UnsplashRandom")

-- Keybindings for launching apps
local appKeys = {
	a = "Slack",
	c = "Google Chrome",
	d = "DataGrip",
	l = "Telegram",
	m = "Spark",
	p = "Postman",
	s = "Spotify",
	t = "iTerm",
	v = "Visual Studio Code",
	w = "WhatsApp",
	x = "Firefox Developer Edition",
}

Install:andUse("Caffeine", {
	hotkeys = {
		toggle = { hyper, "/" },
	},
	start = true,
})

hs.hotkey.bind({ "cmd", "shift" }, "V", function()
	hs.eventtap.keyStrokes(hs.pasteboard.getContents())
end)

-- Sizing windows
local function resize_window(key)
	local win = hs.window.focusedWindow()
	local f = win:frame()
	local screen = win:screen()
	local max = screen:frame()

	f.y = max.y
	f.h = max.h

	if key == "1" then
		f.x = max.x
		f.w = max.w / 2
	elseif key == "2" then
		f.x = max.x + (max.w / 2)
		f.w = max.w / 2
	elseif key == "0" then
		f.x = max.x
		f.w = max.w
	end

	win:setFrame(f)
end

local sizing_keys = { "0", "1", "2" }

for _, value in ipairs(sizing_keys) do
	hs.hotkey.bind(hyper, value, function()
		resize_window(value)
	end)
end

-- Bind appKeys
for key, app in pairs(appKeys) do
	hs.hotkey.bind(hyper, key, function()
		hs.application.launchOrFocus(app)
	end)
end

-- FadeLogo is last to ensure that it confirms hammerspoon has fully loaded successfully
Install:andUse("FadeLogo", {
	config = {
		fade_in_time = 0,
		run_time = 0,
		fade_out_time = 0.4,
	},
	start = true,
})
