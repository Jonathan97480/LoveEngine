Slider component

Usage:
local Slider = require("my-librairie.hud.slider.slider")
local s = Slider.new({ x=10, y=10, w=200, min=0, max=100, value=50, onChange = function(v) print('val',v) end })
function love.update(dt) s.update(dt) end
function love.draw() s.draw() end
function love.mousepressed(x,y,button) s.mousepressed(x,y) end
function love.mousereleased(x,y,button) s.mousereleased(x,y) end

Purpose: horizontal slider for settings or HUD.
