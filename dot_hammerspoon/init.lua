hs.loadSpoon("ShiftIt")
spoon.ShiftIt:bindHotkeys({})

mod = { "option", "shift", "command" }
mod2 = { "option", "shift", "command", "ctrl" }
mod3 = { "option", "shift", "control" }

hs.window.animationDuration = 0.3

-- windowの整列
hs.grid.setGrid("12x4")
hs.grid.setMargins("4x4")

local function setWindowPosition(grid_param)
	local win = hs.window.focusedWindow()
	hs.grid.set(win, grid_param)
end

---- 3画面
hs.hotkey.bind(mod, "left", function()
	setWindowPosition("0,0,4x4")
end)
hs.hotkey.bind(mod, "up", function()
	setWindowPosition("4,0,4x4")
end)
hs.hotkey.bind(mod, "right", function()
	setWindowPosition("8,0,4x4")
end)
---- 3画面 6分割
hs.hotkey.bind(mod, "a", function()
	setWindowPosition("0,0,4x2")
end)
hs.hotkey.bind(mod, "z", function()
	setWindowPosition("0,2,4x2")
end)
hs.hotkey.bind(mod, "s", function()
	setWindowPosition("4,0,4x2")
end)
hs.hotkey.bind(mod, "x", function()
	setWindowPosition("4,2,4x2")
end)
hs.hotkey.bind(mod, "d", function()
	setWindowPosition("8,0,4x2")
end)
hs.hotkey.bind(mod, "c", function()
	setWindowPosition("8,2,4x2")
end)

---- 3画面 中央広め
hs.hotkey.bind(mod2, "left", function()
	setWindowPosition("0,0,3x4")
end)
hs.hotkey.bind(mod2, "up", function()
	setWindowPosition("3,0,6x4")
end)
hs.hotkey.bind(mod2, "right", function()
	setWindowPosition("9,0,3x4")
end)
---- 3画面 中央広め サイド分割
hs.hotkey.bind(mod2, "a", function()
	setWindowPosition("0,0,3x2")
end)
hs.hotkey.bind(mod2, "z", function()
	setWindowPosition("0,2,3x2")
end)
hs.hotkey.bind(mod2, "s", function()
	setWindowPosition("9,0,3x2")
end)
hs.hotkey.bind(mod2, "x", function()
	setWindowPosition("9,2,3x2")
end)

---- リサイズ
hs.hotkey.bind(mod3, "h", function()
	hs.grid.resizeWindowThinner(hs.window.focusedWindow())
end)
hs.hotkey.bind(mod3, "l", function()
	hs.grid.resizeWindowWider(hs.window.focusedWindow())
end)
hs.hotkey.bind(mod3, "k", function()
	hs.grid.resizeWindowShorter(hs.window.focusedWindow())
end)
hs.hotkey.bind(mod3, "j", function()
	hs.grid.resizeWindowTaller(hs.window.focusedWindow())
end)

---- ウィンドウの移動
hs.hotkey.bind(mod3, "left", function()
	hs.grid.pushWindowLeft(hs.window.focusedWindow())
end)
hs.hotkey.bind(mod3, "right", function()
	hs.grid.pushWindowRight(hs.window.focusedWindow())
end)
hs.hotkey.bind(mod3, "up", function()
	hs.grid.pushWindowUp(hs.window.focusedWindow())
end)
hs.hotkey.bind(mod3, "down", function()
	hs.grid.pushWindowDown(hs.window.focusedWindow())
end)

-- source: https://gist.github.com/cwagner22/13e772cda1c4ad80d23452e530f4b760
local scrollMouseButton = 2
local deferred = false

OverrideOtherMouseDown = hs.eventtap.new({ hs.eventtap.event.types.rightMouseDown }, function(e)
	deferred = true
	return true
end)

OverrideOtherMouseUp = hs.eventtap.new({ hs.eventtap.event.types.rightMouseUp }, function(e)
	if deferred then
		OverrideOtherMouseDown:stop()
		OverrideOtherMouseUp:stop()
		hs.eventtap.rightClick(e:location(), pressedMouseButton)
		OverrideOtherMouseDown:start()
		OverrideOtherMouseUp:start()
		return true
	end
	return false
end)

local oldmousepos = {}
local scrollmult = 3 -- negative multiplier makes mouse work like traditional scrollwheel

DragOtherToScroll = hs.eventtap.new({ hs.eventtap.event.types.rightMouseDragged }, function(e)
	deferred = false
	oldmousepos = hs.mouse.getAbsolutePosition()
	local dx = e:getProperty(hs.eventtap.event.properties["mouseEventDeltaX"])
	local dy = e:getProperty(hs.eventtap.event.properties["mouseEventDeltaY"])
	local scroll = hs.eventtap.event.newScrollEvent({ dx * scrollmult, dy * scrollmult }, {}, "pixel")
	-- put the mouse back
	hs.mouse.setAbsolutePosition(oldmousepos)
	return true, { scroll }
end)

OverrideOtherMouseDown:start()
OverrideOtherMouseUp:start()
DragOtherToScroll:start()

-- フォーカスされたアプリが Terminal.app または VSCode のとき、英数モードに切り替える

local targetApps = {
	["Safari"] = true,
	["Chrome"] = true,
	["Ghostty"] = true,
	["ChatGPT"] = true,
	["Code"] = true,
	["Obsidian"] = true,
}

local function switchToEisuu(appName)
	if targetApps[appName] then
		hs.eventtap.keyStroke({ "ctrl", "shift" }, ";") -- 「英数」キーを送信
	end
end

hs.application.watcher
	.new(function(appName, eventType)
		if eventType == hs.application.watcher.activated then
			print("App activated: " .. appName)
			switchToEisuu(appName)
		end
	end)
	:start()
