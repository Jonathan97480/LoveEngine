Checkbox component

Usage:
local Checkbox = require("my-librairie.hud.checkbox.checkbox")
local c = Checkbox.new({ x=10, y=10, size=24, checked=false, onChange = function(v) print('checked',v) end })
function love.draw() c.draw() end
function love.mousepressed(x,y,button) c.mousepressed(x,y) end

Purpose: simple toggle control for HUD.
