Panel component

Usage:
local Panel = require("my-librairie.hud.panel.panel")
local p = Panel.new({ x = 10, y = 10, w = 300, h = 200 })
function love.draw() p.draw() end

Purpose: lightweight container to group HUD elements and draw a background.
